-- AI (utility): Assume actions "MoveToPoint()" and "Attack()" are player-issued commands (as a result, do not interrupt them) --

function GT_AI_Utility_DoNotOverridePlayerCommands()
	if EEex_LuaTrigger_Object.m_curAction.m_actionID == 3 or EEex_LuaTrigger_Object.m_curAction.m_actionID == 23 then
		return false
	else
		return true
	end
end

-- AI (utility): equip most damaging melee (check if the active creature has a melee weapon to begin with, so as to avoid equipping "FIST.ITM"...) --

function GT_AI_Utility_EquipMostDamagingMelee()
	local equipMostDamagingMelee = false
	--
	if EEex_LuaAction_Object.m_typeAI.m_Class == 20 then -- CLASS=MONK
		equipMostDamagingMelee = true
	else
		local items = EEex_LuaAction_Object.m_equipment.m_items -- Array<CItem*,39>
		for i = 35, 38 do -- WEAPON[1-4]
			local item = items:get(i) -- CItem
			if item then
				local ability = EEex_Resource_GetCItemAbility(item, 0)
				if ability.type == 1 then -- melee
					equipMostDamagingMelee = true
					break
				end
			end
		end
	end
	--
	if equipMostDamagingMelee then
		local equipMostDamagingMelee = EEex_Action_ParseResponseString("EquipMostDamagingMelee()")
		equipMostDamagingMelee:queueResponseOnAIBase(EEex_LuaAction_Object)
		equipMostDamagingMelee:free()
	end
end

-- AI (utility): Look for ``PC`` --

function GT_AI_Utility_LookForPCs(array, string)
	local toReturn = {}
	local sourceEA = EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly
	--
	if (sourceEA > 200 and string == "sourceAndTargetEnemies") or (sourceEA < 30 and string == "sourceAndTargetAllies") then
		-- Duplicate the values
		for i = #array, 1, -1 do
			table.insert(toReturn, 1, array[i])
			local pc = string.gsub(array[i], "<EA_PLACEHOLDER>", "PC")
			table.insert(toReturn, 1, pc)
		end
	else
		toReturn = array
	end
	--
	return toReturn
end

-- AI (utility): Look for ``HATEDRACE`` --

function GT_AI_Utility_LookForHatedRace(array)
	local toReturn = array
	local sourceHatedRaceIDS = EEex_LuaTrigger_Object.m_derivedStats.m_nHatedRace
	--
	if sourceHatedRaceIDS > 0 then
		-- Duplicate the values
		local i = 1
		while i <= #toReturn do
			if string.find(toReturn[i], "<HATEDRACE_PLACEHOLDER>") then
				local hatedRaceSymbol = string.gsub(toReturn[i], "<HATEDRACE_PLACEHOLDER>", GT_Resource_IDSToSymbol["race"][sourceHatedRaceIDS])
				table.insert(toReturn, i, hatedRaceSymbol)
				i = i + 1 -- Skip the newly inserted element to avoid infinite loop
				toReturn[i] = string.gsub(toReturn[i], "<HATEDRACE_PLACEHOLDER>", "0")
			end
			i = i + 1
		end
	else
		for i = #toReturn, 1, -1 do
			toReturn[i] = string.gsub(toReturn[i], "<HATEDRACE_PLACEHOLDER>", "0")
		end
	end
	--
	return toReturn
end

-- AI (utility): Replace ``EA_PLACEHOLDER`` with ``GOODCUTOFF`` / ``EVILCUTOFF``

function GT_AI_Utility_ResolveEA(array, string)
	local toReturn = array
	local sourceEA = EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly
	--
	if string == "sourceAndTargetEnemies" then
		if sourceEA > 200 then
			for i = 1, #toReturn do
				toReturn[i] = string.gsub(toReturn[i], "<EA_PLACEHOLDER>", "GOODCUTOFF")
			end
		elseif sourceEA < 30 then
			for i = 1, #toReturn do
				toReturn[i] = string.gsub(toReturn[i], "<EA_PLACEHOLDER>", "EVILCUTOFF")
			end
		else
			return toReturn
		end
	elseif string == "sourceAndTargetAllies" then
		if sourceEA > 200 then
			for i = 1, #toReturn do
				toReturn[i] = string.gsub(toReturn[i], "<EA_PLACEHOLDER>", "EVILCUTOFF")
			end
		elseif sourceEA < 30 then
			for i = 1, #toReturn do
				toReturn[i] = string.gsub(toReturn[i], "<EA_PLACEHOLDER>", "GOODCUTOFF")
			end
		else
			return toReturn
		end
	else
		return toReturn
	end
	--
	return toReturn
end

-- AI (utility): Sort ``CGameArea::GetAllInRange()`` output --

function GT_AI_Utility_SortSprites(array)
	local temp = {}
	local sourceX = EEex_LuaTrigger_Object.m_pos.x
	local sourceY = EEex_LuaTrigger_Object.m_pos.y
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

-- AI (utility): Shuffle ``CGameArea::GetAllInRange()`` output --

function GT_AI_Utility_ShuffleSprites(array)
	local shuffledArray = {}
	for i = #array, 1, -1 do
		local rand = math.random(i)
		table.insert(shuffledArray, table.remove(array, rand))
	end
	return shuffledArray
end

-- AI (utility): Check if spellcasting is not disabled --

function GT_AI_Utility_SpellcastingDisabled(header, ability)
	local toReturn = false
	local found = false
	--
	local spellcastingDisabled = function(fx)
		if ability.quickSlotType == 2 and fx.m_effectId == 144 and fx.m_dWFlags == 2 then -- location: cast spell button
			found = true
			return true
		end
		if ability.quickSlotType == 4 and fx.m_effectId == 144 and fx.m_dWFlags == 13 then -- location: innate ability button
			found = true
			return true
		end
		--
		if ability.quickSlotType == 2 and fx.m_effectId == 145 and fx.m_dWFlags == 0 and header.itemType == 1 then
			found = true
			return true
		end
		if ability.quickSlotType == 2 and fx.m_effectId == 145 and fx.m_dWFlags == 1 and header.itemType == 2 then
			found = true
			return true
		end
		if fx.m_effectId == 145 and fx.m_dWFlags == 2 and not (header.itemType == 1 or header.itemType == 2) then
			found = true
			return true
		end
		if fx.m_effectId == 145 and fx.m_dWFlags == 3 and EEex_IsBitUnset(header.itemFlags, 14) then
			found = true
			return true
		end
	end
	--
	if EEex_Sprite_GetStat(EEex_LuaTrigger_Object, 59) == 1 and ability.quickSlotType == 2 and (header.itemType == 1 or header.itemType == 2) then
		toReturn = true
	else
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, spellcastingDisabled)
		if not found then
			EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, spellcastingDisabled)
		end
		--
		if found then
			toReturn = true
		end
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce mschool --

function GT_AI_Utility_MschoolCheck(mschool, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local found = false
	local isImmuneOrCanBounce = function(fx)
		if (fx.m_effectId == 0xCA or fx.m_effectId == 0xCC or fx.m_effectId == 0xDF or fx.m_effectId == 0xE3) and fx.m_dWFlags == mschool then
			found = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounce)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounce)
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == mschool and fx.m_scriptName:get() == "mschoolCheck" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if found then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["m_effectAmount3"] = mschool,
					["m_scriptName"] = "mschoolCheck",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce msectype --

function GT_AI_Utility_MsectypeCheck(msectype, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local found = false
	local isImmuneOrCanBounce = function(fx)
		if (fx.m_effectId == 0xCB or fx.m_effectId == 0xCD or fx.m_effectId == 0xE2 or fx.m_effectId == 0xE4) and fx.m_dWFlags == msectype then
			found = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounce)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounce)
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == msectype and fx.m_scriptName:get() == "msectypeCheck" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if found then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["m_effectAmount3"] = msectype,
					["m_scriptName"] = "msectypeCheck",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce resref --

function GT_AI_Utility_ResrefCheck(resref, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local found = false
	local isImmuneOrCanBounce = function(fx)
		if (fx.m_effectId == 0xCE or fx.m_effectId == 0xCF) and fx.m_res:get() == resref then
			found = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounce)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounce)
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_res:get() == resref and fx.m_scriptName:get() == "resrefCheck" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if found then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["res"] = resref,
					["m_scriptName"] = "resrefCheck",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce projectile --

function GT_AI_Utility_ProjectileCheck(ability, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	local projectileIdx = ability.missileType - 1
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local found = false
	local isImmuneOrCanBounce = function(fx)
		if (fx.m_effectId == 0x53 or fx.m_effectId == 0xC5) and fx.m_dWFlags == projectileIdx then
			found = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounce)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounce)
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == projectileIdx and fx.m_scriptName:get() == "projectileCheck" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if found then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["m_effectAmount3"] = projectileIdx,
					["m_scriptName"] = "projectileCheck",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce / can trap power level --

function GT_AI_Utility_PowerLevelCheck(msectype, header, ability, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local powerLevel = 0
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local effectsCount = ability.effectCount
	if effectsCount > 0 then
		local currentEffectAddress = EEex_UDToPtr(header) + header.effectsOffset + ability.startingEffect * Item_effect_st.sizeof
		--
		for i = 1, effectsCount do
			local effect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
			if effect.spellLevel > 0 then
				powerLevel = effect.spellLevel
				break
			end
			currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
		end
		--
		if powerLevel > 0 then
			local found = false
			local isImmuneOrCanBounceOrCanTrap = function(fx)
				if fx.m_effectId == 0x66 and fx.m_effectAmount == powerLevel then -- CAN block effects of Secondary Type ``MagicAttack``
					found = true
					return true
				end
				if fx.m_effectId == 0xC7 and fx.m_effectAmount == powerLevel and not (msectype == 4) then -- CANNOT bounce effects of Secondary Type ``MagicAttack``
					found = true
					return true
				end
				if (fx.m_effectId == 0xC8 or fx.m_effectId == 0xC9 or fx.m_effectId == 0x103) and fx.m_dWFlags == powerLevel and not (msectype == 4) then -- CANNOT block/bounce/trap effects of Secondary Type ``MagicAttack``
					found = true
					return true
				end
			end
			EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounceOrCanTrap)
			if not found then
				EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounceOrCanTrap)
			end
			--
			local timerExpired = false
			local timerAlreadyApplied = false
			EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
				if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == powerLevel and fx.m_scriptName:get() == "powerLevelCheck" then
					if fx.m_durationType == 1 then
						timerExpired = true
						return true
					else
						timerAlreadyApplied = true
						return true
					end
				end
			end)
			--
			if found then
				if timerExpired then
					-- do nothing, target not valid
				else
					if not timerAlreadyApplied then
						EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
						{
							["effectID"] = 401, -- Set extended stat
							["special"] = stats["GT_AI_TIMER"],
							["dwFlags"] = 1, -- mode: set
							["effectAmount"] = 1,
							["durationType"] = 4,
							["duration"] = 6 * math.random(dnum, dnum * dsize),
							["m_effectAmount2"] = uuid,
							["m_effectAmount3"] = powerLevel,
							["m_scriptName"] = "powerLevelCheck",
							["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
							["sourceID"] = EEex_LuaTrigger_Object.m_id,
							["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
						})
					end
					toReturn = true
				end
			else
				toReturn = true
			end
		else
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- AI (utility): Check if the target is immune / can bounce opcode(s) --

function GT_AI_Utility_OpcodeCheck(array, sprite)
	local toReturn = false
	local uuid = sprite:getUUID()
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	for _, v in ipairs(array) do
		local found = false
		local isImmuneOrCanBounce = function(fx)
			if (fx.m_effectId == 0x65 or fx.m_effectId == 0xC6) and fx.m_dWFlags == v then
				found = true
				return true
			end
		end
		EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, isImmuneOrCanBounce)
		if not found then
			EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, isImmuneOrCanBounce)
		end
		--
		local timerExpired = false
		local timerAlreadyApplied = false
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == v and fx.m_scriptName:get() == "opcodeCheck" then
				if fx.m_durationType == 1 then
					timerExpired = true
					return true
				else
					timerAlreadyApplied = true
					return true
				end
			end
		end)
		--
		if found then
			if timerExpired then
				-- do nothing, target not valid
			else
				if not timerAlreadyApplied then
					EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
					{
						["effectID"] = 401, -- Set extended stat
						["special"] = stats["GT_AI_TIMER"],
						["dwFlags"] = 1, -- mode: set
						["effectAmount"] = 1,
						["durationType"] = 4,
						["duration"] = 6 * math.random(dnum, dnum * dsize),
						["m_effectAmount2"] = uuid,
						["m_effectAmount3"] = v,
						["m_scriptName"] = "opcodeCheck",
						["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
						["sourceID"] = EEex_LuaTrigger_Object.m_id,
						["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
					})
				end
				toReturn = true
			end
		else
			toReturn = true
		end
	end
	--
	return toReturn
end

-- AI (utility): Check target flags (SPLSTATEs) --

function GT_AI_Utility_CheckSpellState(array, sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	local uuid = sprite:getUUID()
	local stats = GT_Resource_SymbolToIDS["stats"]
	local splstate = GT_Resource_SymbolToIDS["splstate"]
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local count = 0
	local bit = nil
	local checkSpellState = nil
	for _, v in ipairs(array) do -- {'!=','WIZARD_SHIELD'}
		local comparison = v[1] -- '!='
		local symbol = v[2] -- 'WIZARD_SHIELD'
		--
		if comparison == "==" then
			checkSpellState = EEex_Trigger_ParseConditionalString(string.format("CheckSpellState(EEex_LuaObject,%s)", symbol))
			bit = 0x20 -- bit5
		elseif comparison == "!=" then
			checkSpellState = EEex_Trigger_ParseConditionalString(string.format("!CheckSpellState(EEex_LuaObject,%s)", symbol))
			bit = 0x40 -- bit6
		end
		--
		local timerExpired = false
		local timerAlreadyApplied = false
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == splstate[symbol] and fx.m_savingThrow == bit and fx.m_scriptName:get() == "checkSpellState" then
				if fx.m_durationType == 1 then
					timerExpired = true
					return true
				else
					timerAlreadyApplied = true
					return true
				end
			end
		end)
		--
		if not checkSpellState:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
			if timerExpired then
				-- do nothing, target not valid
			else
				if not timerAlreadyApplied then
					EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
					{
						["effectID"] = 401, -- Set extended stat
						["special"] = stats["GT_AI_TIMER"],
						["dwFlags"] = 1, -- mode: set
						["effectAmount"] = 1,
						["durationType"] = 4,
						["duration"] = 6 * math.random(dnum, dnum * dsize),
						["m_effectAmount2"] = uuid,
						["m_effectAmount3"] = splstate[symbol],
						["savingThrow"] = bit,
						["m_scriptName"] = "checkSpellState",
						["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
						["sourceID"] = EEex_LuaTrigger_Object.m_id,
						["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
					})
				end
				count = count + 1
			end
		else
			count = count + 1
		end
	end
	--
	if count == #array then
		toReturn = true
	end
	--
	checkSpellState:free()
	return toReturn
end

-- AI (utility): Check target flags (STATEs) --

function GT_AI_Utility_StateCheck(array, sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	local uuid = sprite:getUUID()
	local stats = GT_Resource_SymbolToIDS["stats"]
	local state = GT_Resource_SymbolToIDS["state"]
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local count = 0
	local bit = nil
	local stateCheck = nil
	for _, v in ipairs(array) do -- {'!','STATE_MIRRORIMAGE'}
		local comparison = v[1] -- '!'
		local symbol = v[2] -- 'STATE_MIRRORIMAGE'
		--
		if comparison == "&" then
			stateCheck = EEex_Trigger_ParseConditionalString(string.format("StateCheck(EEex_LuaObject,%s)", symbol))
			bit = 0x20 -- bit5
		elseif comparison == "!" then
			stateCheck = EEex_Trigger_ParseConditionalString(string.format("!StateCheck(EEex_LuaObject,%s)", symbol))
			bit = 0x40 -- bit6
		end
		--
		local timerExpired = false
		local timerAlreadyApplied = false
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == state[symbol] and fx.m_savingThrow == bit and fx.m_scriptName:get() == "stateCheck" then
				if fx.m_durationType == 1 then
					timerExpired = true
					return true
				else
					timerAlreadyApplied = true
					return true
				end
			end
		end)
		--
		if not stateCheck:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
			if timerExpired then
				-- do nothing, target not valid
			else
				if not timerAlreadyApplied then
					EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
					{
						["effectID"] = 401, -- Set extended stat
						["special"] = stats["GT_AI_TIMER"],
						["dwFlags"] = 1, -- mode: set
						["effectAmount"] = 1,
						["durationType"] = 4,
						["duration"] = 6 * math.random(dnum, dnum * dsize),
						["m_effectAmount2"] = uuid,
						["m_effectAmount3"] = state[symbol],
						["savingThrow"] = bit,
						["m_scriptName"] = "stateCheck",
						["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
						["sourceID"] = EEex_LuaTrigger_Object.m_id,
						["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
					})
				end
				count = count + 1
			end
		else
			count = count + 1
		end
	end
	--
	if count == #array then
		toReturn = true
	end
	--
	stateCheck:free()
	return toReturn
end

-- AI (utility): Check target flags (STATS) --

function GT_AI_Utility_CheckStat(array, sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	local uuid = sprite:getUUID()
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local count = 0
	local bit = nil
	local checkStat = nil
	for _, v in ipairs(array) do -- {'RESISTCOLD','<',60}
		local symbol = v[1] -- 'RESISTCOLD'
		local comparison = v[2] -- '<'
		local amount = v[3] -- '60'
		--
		if comparison == "==" then
			checkStat = EEex_Trigger_ParseConditionalString(string.format("CheckStat(EEex_LuaObject,%d,%s)", amount, symbol))
			bit = 0x20 -- bit5
		elseif comparison == "!=" then
			checkStat = EEex_Trigger_ParseConditionalString(string.format("!CheckStat(EEex_LuaObject,%d,%s)", amount, symbol))
			bit = 0x40 -- bit6
		elseif comparison == "<" then
			checkStat = EEex_Trigger_ParseConditionalString(string.format("CheckStatLT(EEex_LuaObject,%d,%s)", amount, symbol))
			bit = 0x80 -- bit7
		elseif comparison == ">" then
			checkStat = EEex_Trigger_ParseConditionalString(string.format("CheckStatGT(EEex_LuaObject,%d,%s)", amount, symbol))
			bit = 0x100 -- bit8
		end
		--
		local timerExpired = false
		local timerAlreadyApplied = false
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_effectAmount3 == stats[symbol] and fx.m_savingThrow == bit and fx.m_effectAmount4 == amount and fx.m_scriptName:get() == "checkStat" then
				if fx.m_durationType == 1 then
					timerExpired = true
					return true
				else
					timerAlreadyApplied = true
					return true
				end
			end
		end)
		--
		if not checkStat:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
			if timerExpired then
				-- do nothing, target not valid
			else
				if not timerAlreadyApplied then
					EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
					{
						["effectID"] = 401, -- Set extended stat
						["special"] = stats["GT_AI_TIMER"],
						["dwFlags"] = 1, -- mode: set
						["effectAmount"] = 1,
						["durationType"] = 4,
						["duration"] = 6 * math.random(dnum, dnum * dsize),
						["m_effectAmount2"] = uuid,
						["m_effectAmount3"] = stats[symbol],
						["m_effectAmount4"] = amount,
						["savingThrow"] = bit,
						["m_scriptName"] = "checkStat",
						["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
						["sourceID"] = EEex_LuaTrigger_Object.m_id,
						["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
					})
				end
				count = count + 1
			end
		else
			count = count + 1
		end
	end
	--
	if count == #array then
		toReturn = true
	end
	--
	checkStat:free()
	return toReturn
end

-- AI (utility): Check if the currently equipped weapon can hit the current target --

function GT_AI_Utility_WeaponEffectiveVs(resref, sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local weaponEffectiveVs = EEex_Trigger_ParseConditionalString("WeaponEffectiveVs(EEex_LuaObject,MAINHAND)")
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_res:get() == resref and fx.m_scriptName:get() == "weaponEffectiveVs" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if not weaponEffectiveVs:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["res"] = resref,
					["m_scriptName"] = "weaponEffectiveVs",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	weaponEffectiveVs:free()
	return toReturn
end

-- AI (utility): Check if the currently equipped weapon can damage the current target --

function GT_AI_Utility_WeaponCanDamage(resref, sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	local uuid = sprite:getUUID()
	--
	local sourceINT = EEex_LuaTrigger_Object.m_derivedStats.m_nINT
	--
	local intmod = GT_Resource_2DA["intmod"]
	local dnum = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_NUM"])
	local dsize = tonumber(intmod[string.format("%s", sourceINT)]["MAZE_DURATION_DICE_SIZE"])
	--
	local weaponCanDamage = EEex_Trigger_ParseConditionalString("WeaponCanDamage(EEex_LuaObject,MAINHAND)")
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_AI_TIMER"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_effectAmount2 == uuid and fx.m_res:get() == resref and fx.m_scriptName:get() == "weaponCanDamage" then
			if fx.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	if not weaponCanDamage:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = uuid,
					["res"] = resref,
					["m_scriptName"] = "weaponCanDamage",
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	weaponCanDamage:free()
	return toReturn
end

-- AI (utility): Check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

function GT_AI_Utility_InParty(sprite)
	EEex_LuaObject = sprite -- must be global
	local toReturn = false
	--
	local inParty = EEex_Trigger_ParseConditionalString("InParty(EEex_LuaObject)")
	--
	local attackerEA = EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly
	--
	if attackerEA > 200 then -- EVILCUTOFF
		toReturn = true
	else
		if not inParty:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
			toReturn = true
		end
	end
	--
	inParty:free()
	return toReturn
end

-- AI (utility): Clear timers when combat ends --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that clears the timers
	local clear = function()
		-- Mark the creature as 'timers removed'
		sprite:setLocalInt("gtAIClearTimers", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
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
