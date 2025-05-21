--[[
+------------------------+
| Utility functions (AI) |
+------------------------+
--]]

-- Assume actions "MoveToPoint()" and "Attack()" are player-issued commands (as a result, do not interrupt them) --

function GT_AI_InterruptableActions()
	return not (EEex_LuaTrigger_Object.m_curAction.m_actionID == 3 or EEex_LuaTrigger_Object.m_curAction.m_actionID == 23)
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
			local aux = EEex_GetUDAux(itrSprite)
			--
			if aux["gtAI_DetectableStates_Aux"] then
				aux["gtAI_DetectableStates_Aux"] = nil
			end
		end
	end
end

-- Check if the target is affected by effects from the specified resref --

function GT_AI_ResRefCheck(resref)
	local toReturn = false
	--
	local func = function(effect)
		if effect.m_sourceRes:get() == resref then
			toReturn = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, func)
	if not toReturn then
		-- guess we can safely ignore equipped effects, right...?
		--EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, func)
	end
	--
	return toReturn
end

-- AoE radius check (try avoiding friendly fire) --

function GT_AI_AoERadiusCheck(missileType, scriptRunner, targetSprite)
	local toReturn = true
	--
	if scriptRunner == nil then
		scriptRunner = EEex_LuaTrigger_Object -- CGameSprite
	end
	--
	local proResRef = GT_Resource_IDSToSymbol["projectl"][missileType - 1]
	--local abilityTarget = pAbility.actionType
	--
	if proResRef then -- sanity check
		local pHeader = EEex_Resource_Demand(proResRef, "pro")
		--
		if pHeader then -- sanity check
			local m_wFileType = pHeader.m_wFileType
			--
			if m_wFileType == 3 then -- AoE
				toReturn = false
				-- NB.: the projectile starts at an offset from the caster!!!
				local projX, projY, projZ = EEex_Projectile_GetStartingPosForID(missileType, scriptRunner, {
					["targetObject"] = targetSprite,
				})
				--
				local m_dwAreaFlags = pHeader.m_dwAreaFlags
				--local m_triggerRange = pHeader.m_triggerRange
				local m_explosionRange = pHeader.m_explosionRange
				local m_coneSize = pHeader.m_coneSize
				--
				local allies, enemies = {}, {}
				local alliesWithinRange, enemiesWithinRange = 0, 0
				--
				if targetSprite.m_typeAI.m_EnemyAlly < 30 then -- [GOODCUTOFF]
					if EEex_IsBitSet(m_dwAreaFlags, 11) then -- cone
						allies = scriptRunner.m_pArea:getAllOfTypeInRange(projX, projY, GT_AI_ObjectType["GOODCUTOFF"], m_explosionRange)
						enemies = scriptRunner.m_pArea:getAllOfTypeInRange(projX, projY, GT_AI_ObjectType["EVILCUTOFF"], m_explosionRange)
					else -- circle
						allies = EEex_Sprite_GetAllOfTypeInRange(targetSprite, GT_AI_ObjectType["GOODCUTOFF"], m_explosionRange, nil, nil, nil)
						enemies = EEex_Sprite_GetAllOfTypeInRange(targetSprite, GT_AI_ObjectType["EVILCUTOFF"], m_explosionRange, nil, nil, nil)
					end
				elseif targetSprite.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
					if EEex_IsBitSet(m_dwAreaFlags, 11) then -- cone
						allies = scriptRunner.m_pArea:getAllOfTypeInRange(projX, projY, GT_AI_ObjectType["EVILCUTOFF"], m_explosionRange)
						enemies = scriptRunner.m_pArea:getAllOfTypeInRange(projX, projY, GT_AI_ObjectType["GOODCUTOFF"], m_explosionRange)
					else -- circle
						allies = EEex_Sprite_GetAllOfTypeInRange(targetSprite, GT_AI_ObjectType["EVILCUTOFF"], m_explosionRange, nil, nil, nil)
						enemies = EEex_Sprite_GetAllOfTypeInRange(targetSprite, GT_AI_ObjectType["GOODCUTOFF"], m_explosionRange, nil, nil, nil)
					end
				end
				--
				if EEex_IsBitUnset(m_dwAreaFlags, 0x6) and EEex_IsBitUnset(m_dwAreaFlags, 0x7) then -- party-unfriendly, try avoiding friendly fire (see f.i. Fireball, Arrow of Detonation)
					for _, itrSprite in ipairs(enemies) do
						if EEex_IsBitUnset(m_dwAreaFlags, 11) or GT_Sprite_TestCone(m_coneSize, projX, projY, targetSprite.m_pos.x, targetSprite.m_pos.y, itrSprite.m_pos.x, itrSprite.m_pos.y) then
							enemiesWithinRange = 1
							goto continue
						end
					end
					--
					for _, itrSprite in ipairs(allies) do
						if itrSprite.m_id ~= targetSprite.m_id then -- skip main target in case of cones
							if EEex_IsBitUnset(m_dwAreaFlags, 11) or GT_Sprite_TestCone(m_coneSize, projX, projY, targetSprite.m_pos.x, targetSprite.m_pos.y, itrSprite.m_pos.x, itrSprite.m_pos.y) then
								alliesWithinRange = alliesWithinRange + 1
							end
						end
					end
				elseif EEex_IsBitSet(m_dwAreaFlags, 0x6) then -- party-friendly, see f.i. Bless/Haste/Curse
					for _, itrSprite in ipairs(allies) do
						if itrSprite.m_id ~= targetSprite.m_id then -- skip main target in case of cones
							if EEex_IsBitUnset(m_dwAreaFlags, 11) or GT_Sprite_TestCone(m_coneSize, projX, projY, targetSprite.m_pos.x, targetSprite.m_pos.y, itrSprite.m_pos.x, itrSprite.m_pos.y) then
								alliesWithinRange = alliesWithinRange + 1
							end
						end
					end
				end
				--
				::continue::
				if enemiesWithinRange == 0 then
					if #allies == 0 or math.random(0, #allies) <= alliesWithinRange then
						toReturn = true
					end
				end
			end
		end
	end
	--
	return toReturn
end

-- Check if AoE missile (i.e., can bypass some deflection/reflection/trap opcodes) --

function GT_AI_IsAoEMissile(projectileType)
	local flags = 0x0
	local m_secondaryProjectile = -1
	--
	local proResRef = GT_Resource_IDSToSymbol["projectl"][projectileType]
	--
	if proResRef then -- sanity check
		local pHeader = EEex_Resource_Demand(proResRef, "pro")
		--
		if pHeader then -- sanity check
			local m_wFileType = pHeader.m_wFileType
			--
			if m_wFileType == 3 then -- AoE
				flags = 0x4 -- BIT2 (Bypasses deflection/reflection/trap opcodes)
				m_secondaryProjectile = pHeader.m_secondaryProjectile
			end
		end
	end
	--
	return flags, m_secondaryProjectile - 1
end

