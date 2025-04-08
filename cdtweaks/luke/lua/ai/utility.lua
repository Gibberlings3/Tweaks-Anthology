--[[
+------------------------+
| Utility functions (AI) |
+------------------------+
--]]

-- Simple hash function --

function GT_AI_SimpleHash(str)
	local hash = 0
	for i = 1, #str do
		hash = (hash * 31 + str:byte(i)) % 2^31
	end
	-- Ensure the hash is a signed 32-bit integer
	if hash >= 2^31 then
		hash = hash - 2^32
	end
	return hash
end

-- Assume actions "MoveToPoint()" and "Attack()" are player-issued commands (as a result, do not interrupt them) --

function GT_AI_InterruptableActions()
	return not (EEex_LuaTrigger_Object.m_curAction.m_actionID == 3 or EEex_LuaTrigger_Object.m_curAction.m_actionID == 23)
end

-- Check if the aura is free (or under the effects of Improved Alacrity) --

function GT_AI_AuraFree(useItem)
	-- sanity check
	if useItem == nil then
		useItem = false -- default to false if omitted
	elseif type(useItem) ~= "boolean" then
		useItem = true -- default to true if not boolean
	end
	--
	if useItem then
		return EEex_Sprite_GetCastTimer(EEex_LuaTrigger_Object) == -1
	else
		return (EEex_Sprite_GetCastTimer(EEex_LuaTrigger_Object) == -1 or EEex_LuaTrigger_Object:getActiveStats().m_bAuraCleansing > 0)
	end
end

-- Select a weapon (chosen at random from SLOT_WEAPON[1-4] / SLOT_FIST) --

function GT_AI_SelectWeapon()
	local melee = {}
	local ranged = {}
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	local withinMeleeRange = EEex_Trigger_ParseConditionalString("Range(NearestEnemyOf(Myself),4)")
	--
	local items = EEex_LuaTrigger_Object.m_equipment.m_items -- Array<CItem*,39>
	--
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			local ability = EEex_Resource_GetCItemAbility(item, 0) -- Item_ability_st
			--
			if ability.type == 1 then -- melee
				table.insert(melee, i)
			else -- ranged / launcher
				table.insert(ranged, i)
			end
		end
	end
	--
	if EEex_LuaTrigger_Object.m_typeAI.m_Class == 20 or (next(melee) == nil and next(ranged) == nil) then -- CLASS=MONK || no weapon
		table.insert(melee, 10) -- SLOT_FIST
	end
	-- Pick a random index from the arrays
	local randomIndex = -1
	local slotID = -1
	--
	if withinMeleeRange:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and isWeaponRanged:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and next(melee) then
		randomIndex = math.random(#melee)
		slotID = melee[randomIndex]
	elseif not withinMeleeRange:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and not isWeaponRanged:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and next(ranged) then
		randomIndex = math.random(#ranged)
		slotID = ranged[randomIndex]
	end
	--
	isWeaponRanged:free()
	withinMeleeRange:free()
	--
	if randomIndex ~= -1 then
		EEex_LuaTrigger_Object:setLocalInt("gtAISelectWeaponAbility", slotID)
		return true
	else
		return false
	end
end

-- Sort ``CGameArea::GetAllInRange()`` output by (isometric) distance --

function GT_AI_SortSpritesByIsometricDistance(array)
	local temp = {}
	local sourceX = EEex_LuaDecode_Object.m_pos.x
	local sourceY = EEex_LuaDecode_Object.m_pos.y
	--
	for _, v in ipairs(array) do
		local distance = GT_Utility_GetIsometricDistance(sourceX, sourceY, v.m_pos.x, v.m_pos.y)
		temp[v] = distance
	end
	-- Create a table of keys
	local toReturn = {}
	for k in pairs(temp) do table.insert(toReturn, k) end
	-- Sort the keys based on the values in the table
	table.sort(toReturn, function(a, b) return temp[a] < temp[b] end)
	--
	return toReturn
end

-- Shuffle ``CGameArea::GetAllInRange()`` output --

function GT_AI_ShuffleSprites(array)
	local shuffledArray = {}
	for i = #array, 1, -1 do
		local rand = math.random(i)
		table.insert(shuffledArray, table.remove(array, rand))
	end
	return shuffledArray
end

-- Clear AI timers when combat ends --

function GT_AI_ClearTimers()
	-- [Bubb] Each area has its own combat counter. You can check the global script runner's area in this way...
	local globalScriptRunnerId = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nAIIndex
	local globalScriptRunner = EEex_GameObject_Get(globalScriptRunnerId) -- CGameSprite
	local globalScriptRunnerArea = globalScriptRunner.m_pArea -- CGameArea
	--
	if globalScriptRunnerArea and globalScriptRunnerArea.m_nBattleSongCounter <= 0 then
		local everyone = EEex_Area_GetAllOfTypeInRange(globalScriptRunnerArea, globalScriptRunner.m_pos.x, globalScriptRunner.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
		--
		for _, itrSprite in ipairs(everyone) do
			local found = false
			EEex_Utility_IterateCPtrList(itrSprite.m_timedEffectList, function(effect)
				if effect.m_effectId == 401 and effect.m_sourceRes:get() == "GTAITMRS" then
					found = true
					return true
				end
			end)
			--
			if found then
				itrSprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["res"] = "GTAITMRS",
					["noSave"] = true,
					["sourceID"] = itrSprite.m_id,
					["sourceTarget"] = itrSprite.m_id,
				})
			end
		end
	end
end

-- Check if the target is already affected by effects from the specified resref --

function GT_AI_CurrentCastingHasRunOut(resref)
	local toReturn = true
	--
	local found = false
	local currentCastingHasRunOut = function(effect)
		if effect.m_sourceRes:get() == resref then
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, currentCastingHasRunOut)
	if not found then
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, currentCastingHasRunOut)
	end
	--
	if found then
		toReturn = false
	end
	--
	return toReturn
end

