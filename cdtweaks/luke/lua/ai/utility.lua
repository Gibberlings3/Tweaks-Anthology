--[[
+------------------------+
| Utility functions (AI) |
+------------------------+
--]]

-- Simple hash function --

function GT_Utility_AI_SimpleHash(str)
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

function GT_Utility_AI_DoNotOverridePlayerCommands()
	return not (EEex_LuaTrigger_Object.m_curAction.m_actionID == 3 or EEex_LuaTrigger_Object.m_curAction.m_actionID == 23)
end

-- Check if the aura is free (or under the effects of Improved Alacrity) --

function GT_Utility_AI_AuraFree(useItem)
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

function GT_Utility_AI_SelectWeapon()
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
		EEex_LuaTrigger_Object:setLocalInt("gtSelectWeaponAbility", slotID)
		return true
	else
		return false
	end
end

-- Sort ``CGameArea::GetAllInRange()`` output by (isometric) distance --

function GT_Utility_AI_SortSpritesByIsometricDistance(array)
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

function GT_Utility_AI_ShuffleSprites(array)
	local shuffledArray = {}
	for i = #array, 1, -1 do
		local rand = math.random(i)
		table.insert(shuffledArray, table.remove(array, rand))
	end
	return shuffledArray
end

-- Clear timers when combat ends --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that clears the timers
	local clear = function()
		-- Mark the creature as 'timers removed'
		sprite:setLocalInt("gtAIClearTimers", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTAITMRS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check if combat has ended
	local actuallyInCombat = EEex_Trigger_ParseConditionalString("ActuallyInCombat()")
	local spriteEA = sprite.m_typeAI.m_EnemyAlly
	--
	if spriteEA == 3 then -- FAMILIAR
		if sprite:getLocalInt("gtAIClearTimers") == 0 then
			if not actuallyInCombat:evalConditionalAsAIBase(sprite) then
				clear()
			end
		else
			if not actuallyInCombat:evalConditionalAsAIBase(sprite) then
				-- do nothing
			else
				sprite:setLocalInt("gtAIClearTimers", 0)
			end
		end
	end
	--
	actuallyInCombat:free()
end)
