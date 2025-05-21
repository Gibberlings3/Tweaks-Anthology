--[[
+--------------------+
| AI (weapon attack) |
+--------------------+
--]]

-- give priority to your racial enemy (if any) --

local function GT_AI_Attack_HatedRace(array, raceID) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}
	local toReturn = {}

	for _, value in ipairs(array) do
		local newValue
		local dotCount = select(2, string.gsub(value, "%.", "")) -- Count the number of dots in the string; ``select(2, ...)`` retrieves the second value returned by ``string.gsub``, which is the number of substitutions made (i.e., the number of dots in the string)

		if dotCount == 0 then
			-- No dot: append raceID
			newValue = value .. "." .. raceID
		elseif dotCount == 1 then
			-- Exactly one dot: replace everything after the dot with raceID
			newValue = string.gsub(value, "%.(.*)", "." .. raceID)
		else
			-- Two or more dots: replace content between the first and second dots (the ``.-`` ensures that the match is lazy, so it stops at the first occurrence of the second dot)
			newValue = string.gsub(value, "%.(.-)%.", "." .. raceID .. ".", 1) -- The `1` at the end ensures that only the first occurrence is replaced
		end

		-- Add the new value
		table.insert(toReturn, newValue)
		-- Add the original value
		table.insert(toReturn, value)
	end

	return toReturn
end

-- give priority to [PC] (if attacker is [EVILCUTOFF]). Set GOODCUTOFF / EVILCUTOFF accordingly --

local function GT_AI_Attack_EA(array) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}
	local toReturn = {}

	if EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
		for _, value in ipairs(array) do
			local newValue = "PC." .. value

			-- Add the new value
			table.insert(toReturn, newValue)
		end
		--
		for _, value in ipairs(array) do
			local newValue = "GOODCUTOFF." .. value

			-- Add the new value
			table.insert(toReturn, newValue)
		end
	elseif EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
		for _, value in ipairs(array) do
			local newValue = "EVILCUTOFF." .. value

			-- Add the new value
			table.insert(toReturn, newValue)
		end
	end

	return toReturn
end

-- The following module provides functions to calculate SHA digest --

local sha = require("gt.sha2")

-- check if the currently equipped weapon is effective / can deal non-zero damage --

local function GT_AI_Attack_WeaponCheck(weaponResRef, target)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_SIZE"])
	--
	local aux = EEex_GetUDAux(EEex_LuaDecode_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local toReturn = false
	--
	local hash = sha.sha256(weaponResRef)
	--
	EEex_LuaDecode_Object:setStoredScriptingTarget("GT_AI_Attack_WeaponCheck", target)
	local isWeaponValid = EEex_Trigger_ParseConditionalString('WeaponEffectiveVs(EEex_Target("GT_AI_Attack_WeaponCheck"),MAINHAND) \n WeaponCanDamage(EEex_Target("GT_AI_Attack_WeaponCheck"),MAINHAND)')
	--
	if not isWeaponValid:evalConditionalAsAIBase(EEex_LuaDecode_Object) then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 100 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 100,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- op120 not detected: target valid
	end
	--
	::continue::
	isWeaponValid:free()
	return toReturn
end

-- check if the target is immune to the specified level/projectile/school/sectype/resref/opcode(s) --

local function GT_AI_Attack_HasImmunityEffects(target, level, projectileType, school, sectype, resref, opcodes, flags, savetype)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaDecode_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(projectileType) .. tostring(school) .. tostring(sectype) .. resref .. (opcodes and GT_LuaTool_ArrayToString(opcodes) or "nil") .. tostring(flags) .. tostring(savetype))
	--
	local found = GT_Sprite_HasImmunityEffects(target, level, projectileType, school, sectype, resref, opcodes, flags, savetype)
	--
	if found then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 0 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 0,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	return toReturn
end

-- check if the target can bounce the specified level/projectile/school/sectype/resref/opcode(s) --

local function GT_AI_Attack_HasBounceEffects(target, level, projectileType, school, sectype, resref, opcodes, flags)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaDecode_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(projectileType) .. tostring(school) .. tostring(sectype) .. resref .. (opcodes and GT_LuaTool_ArrayToString(opcodes) or "nil") .. tostring(flags))
	--
	local found = GT_Sprite_HasBounceEffects(target, level, projectileType, school, sectype, resref, opcodes, flags)
	--
	if found then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 1 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 1,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	return toReturn
end

-- extra (custom) checks --

local function GT_AI_Attack_ExtraCheck(string, target)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaDecode_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_SIZE"])
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local toReturn = false
	--
	local conditionalString = EEex_Trigger_ParseConditionalString(string)
	--
	local hash = sha.sha256(string)
	--
	if not conditionalString:evalConditionalAsAIBase(target) then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 101 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 101,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	conditionalString:free()
	return toReturn
end

-- check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

local function GT_AI_Attack_InPartyCheck(sprite)
	local toReturn = false
	--
	EEex_LuaDecode_Object:setStoredScriptingTarget("GT_AI_Attack_InPartyCheck", sprite)
	local inParty = EEex_Trigger_ParseConditionalString('InParty(EEex_Target("GT_AI_Attack_InPartyCheck"))')
	--
	local attackerEA = EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly
	--
	if attackerEA > 200 then -- EVILCUTOFF
		toReturn = true
	else
		if not inParty:evalConditionalAsAIBase(EEex_LuaDecode_Object) then
			toReturn = true
		end
	end
	--
	inParty:free()
	--
	return toReturn
end

-- MAIN --

function GT_AI_Attack(table)
	local equipment = EEex_LuaDecode_Object.m_equipment -- CGameSpriteEquipment
	local mainHand = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local mainHandResRef = mainHand.pRes.resref:get()
	local mainHandHeader = mainHand.pRes.pHeader -- Item_Header_st
	local mainHandAbility = EEex_Resource_GetItemAbility(mainHandHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local attackerActiveStats = EEex_Sprite_GetActiveStats(EEex_LuaDecode_Object)
	--
	local mainHandMissileType = mainHandAbility.missileType -- "missile.ids"
	local projectileIndex = mainHandMissileType - 1 -- "projectl.ids"
	local bypassDeflectionReflectionTrap, explosionProjectile
	--
	if mainHandAbility.type == 1 then
		bypassDeflectionReflectionTrap, explosionProjectile = 0, -1
	else
		bypassDeflectionReflectionTrap, explosionProjectile = GT_AI_IsAoEMissile(projectileIndex)
	end
	--
	local toReturn = nil
	--
	local targetIDS = table["targetIDS"] -- f.i.: targetIDS = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MONK", "PLANT.ELF.SHAMAN.0.MALE.NEUTRAL"}
	-- give priority to hated race (if any)
	do
		local m_nHatedRace = attackerActiveStats.m_nHatedRace
		--
		if m_nHatedRace > 0 then
			targetIDS = GT_AI_Attack_HatedRace(targetIDS, m_nHatedRace)
		end
	end
	--
	targetIDS = GT_AI_Attack_EA(targetIDS)
	--
	for _, aiObjectTypeString in ipairs(targetIDS) do
		local spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaDecode_Object, string.format("[%s]", aiObjectTypeString), EEex_LuaDecode_Object:virtual_GetVisualRange(), nil, nil, nil)
		if mainHandAbility.type == 1 then -- melee weapon
			spriteArray = GT_AI_SortSpritesByIsometricDistance(spriteArray)
		else -- ranged / launcher
			spriteArray = GT_AI_ShuffleSprites(spriteArray)
		end
		--
		for _, itrSprite in ipairs(spriteArray) do
			local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
			--
			if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				--
				if itrSpriteActiveStats.m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						--
						if mainHandAbility.type == 1 or GT_AI_AoERadiusCheck(mainHandMissileType, EEex_LuaDecode_Object, itrSprite) then
							--
							if GT_AI_Attack_WeaponCheck(mainHandResRef, itrSprite) then
								--
								if mainHandAbility.type == 1 or GT_AI_Attack_HasImmunityEffects(itrSprite, 0, explosionProjectile == -1 and projectileIndex or explosionProjectile, mainHandAbility.school, mainHandAbility.secondaryType, "", table["opcode"], bypassDeflectionReflectionTrap, table["ignoreOp101"] or 0x0) then
									if mainHandAbility.type == 1 or GT_AI_Attack_HasBounceEffects(itrSprite, 0, explosionProjectile == -1 and projectileIndex or explosionProjectile, mainHandAbility.school, mainHandAbility.secondaryType, "", table["opcode"], bypassDeflectionReflectionTrap) then
										--
										if not table["extra"] or GT_AI_Attack_ExtraCheck(table["extra"], itrSprite) then
											--
											if GT_AI_Attack_InPartyCheck(itrSprite) then
												--
												toReturn = itrSprite -- CGameSprite
												goto continue
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	--
	::continue::
	-- default to the nearest enemy if necessary
	if toReturn == nil then
		local nearest
		if EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			nearest = GT_AI_ObjectType["GOODCUTOFF"]:evalAsAIBase(EEex_LuaDecode_Object)
		elseif EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			nearest = GT_AI_ObjectType["EVILCUTOFF"]:evalAsAIBase(EEex_LuaDecode_Object)
		end
		--
		if EEex_GameObject_IsSprite(nearest) then -- sanity check (``nearest`` may be ``nil`` if invisible...?)
			if EEex_BAnd(nearest:getActiveStats().m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				if nearest:getActiveStats().m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					if EEex_IsBitUnset(nearest:getActiveStats().m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						if GT_AI_Attack_InPartyCheck(nearest) then
							toReturn = nearest -- CGameSprite
						end
					end
				end
			end
		end
	end
	--
	return toReturn -- CGameSprite
end

