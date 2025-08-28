--[[
+--------------------+
| AI (weapon attack) |
+--------------------+
--]]

-- give priority to your racial enemy (if any) --

local function hatedRace(array, raceID) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}
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

local function EA(array) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}
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

local function weaponHit(weaponResRef, target)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["DICE_SIZE"])
	--
	local aux = EEex_GetUDAux(EEex_LuaDecode_Object)
	if not aux["gt_AI_DetectableStates"] then
		aux["gt_AI_DetectableStates"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local toReturn = false
	--
	local hash = sha.sha256(weaponResRef)
	--
	local string = 'WeaponEffectiveVs(EEex_Target("gtWeaponHitTarget"),MAINHAND) \n WeaponCanDamage(EEex_Target("gtWeaponHitTarget"),MAINHAND)'
	--
	if not GT_EvalConditional["parseConditionalString"](EEex_LuaDecode_Object, target, string, "gtWeaponHitTarget") then
		for _, v in ipairs(aux["gt_AI_DetectableStates"]) do
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
		table.insert(aux["gt_AI_DetectableStates"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = m_gameTime + 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
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
	return toReturn
end

-- check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

local function inPartyCheck(target)
	local attackerEA = EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly
	--
	for i = 0, 5 do
		local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
		if partyMember then -- sanity check
			if partyMember.m_id == target.m_id then -- if the target is a party mamber
				if attackerEA < 30 then -- attacker: [GOODCUTOFF]
					return false
				elseif attackerEA > 200 then -- attacker: [EVILCUTOFF]
					break
				end
			end
		end
	end
	--
	return true
end

-- MAIN --

function GT_LuaDecode_Attack(args)
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(EEex_LuaDecode_Object)
	--
	local attackerActiveStats = EEex_Sprite_GetActiveStats(EEex_LuaDecode_Object)
	--
	local missileType = selectedWeapon["ability"].missileType -- "missile.ids"
	local projectileIndex = missileType - 1 -- "projectl.ids"
	local bypassDeflectionReflectionTrap, explosionProjectile
	--
	if selectedWeapon["ability"].type == 1 then -- melee weapon
		bypassDeflectionReflectionTrap, explosionProjectile = 0, -1
	else -- ranged / launcher
		bypassDeflectionReflectionTrap, explosionProjectile = GT_AI_IsAoEMissile(projectileIndex)
	end
	--
	local powerLevel = GT_AI_GetTrueSpellLevel(selectedWeapon["header"], selectedWeapon["ability"], "itm")
	--
	local toReturn = nil
	--
	local targetIDS = args["targetIDS"] -- f.i.: targetIDS = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MONK", "PLANT.ELF.SHAMAN.0.MALE.NEUTRAL"}
	-- give priority to hated race (if any)
	do
		local m_nHatedRace = attackerActiveStats.m_nHatedRace
		--
		if m_nHatedRace > 0 then
			targetIDS = hatedRace(targetIDS, m_nHatedRace)
		end
	end
	--
	targetIDS = EA(targetIDS)
	--
	for _, extra in ipairs(args["extra"]) do -- f.i.: ["extra"] = {{['mirrorImage'] = true, ['stoneSkin'] = true}, {['mirrorImage'] = true}, {['default'] = false}}
		--
		for _, aiObjectTypeString in ipairs(targetIDS) do
			local potentialTargets = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaDecode_Object, string.format("[%s]", aiObjectTypeString), EEex_LuaDecode_Object:virtual_GetVisualRange(), nil, nil, nil)
			if selectedWeapon["ability"].type == 1 then -- melee weapon
				potentialTargets = GT_Sprite_SortByIsometricDistance(potentialTargets)
			else -- ranged / launcher
				potentialTargets = GT_Utility_ShuffleArray(potentialTargets)
			end
			--
			for _, itrSprite in ipairs(potentialTargets) do
				local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
				--
				if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
					--
					if itrSpriteActiveStats.m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
						--
						if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
							--
							if selectedWeapon["ability"].type == 1 or GT_AI_AoERadiusCheck(missileType, EEex_LuaDecode_Object, itrSprite) then
								--
								if weaponHit(selectedWeapon["resref"], itrSprite) then
									--
									if args["forceApplyViaOp177"] or GT_AI_HasImmunityEffects(EEex_LuaDecode_Object, itrSprite, powerLevel, bypassDeflectionReflectionTrap == 0 and projectileIndex or explosionProjectile, selectedWeapon["ability"].school, selectedWeapon["ability"].secondaryType, "", args["opcode"], bypassDeflectionReflectionTrap, args["bypassOp101"] or 0x0, args["immunitiesVia403"] or 0x0) then
										if args["forceApplyViaOp177"] or GT_AI_HasBounceEffects(EEex_LuaDecode_Object, itrSprite, powerLevel, bypassDeflectionReflectionTrap == 0 and projectileIndex or explosionProjectile, selectedWeapon["ability"].school, selectedWeapon["ability"].secondaryType, "", args["opcode"], bypassDeflectionReflectionTrap) then
											if args["forceApplyViaOp177"] or GT_AI_HasTrapEffect(EEex_LuaDecode_Object, itrSprite, powerLevel, selectedWeapon["ability"].secondaryType, bypassDeflectionReflectionTrap) then
												--
												if GT_AI_ExtraCheck(EEex_LuaDecode_Object, itrSprite, extra) then
													--
													if inPartyCheck(itrSprite) then
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
			--
			if EEex_BAnd(nearest:getActiveStats().m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				--
				if nearest:getActiveStats().m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					--
					if EEex_IsBitUnset(nearest:getActiveStats().m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						--
						if inPartyCheck(nearest) then
							toReturn = nearest -- CGameSprite
						end
					end
				end
			end
		end
	end
	--
	if toReturn then -- sanity check
		-- reset attack timer
		local str = 'SetGlobalTimerRandom("gtAttackTimer","LOCALS",6,12)'
		GT_ExecuteResponse["parseResponseString"](EEex_LuaDecode_Object, nil, str)
		-- randomize reevaluation period
		local reevaluationPeriod = {15, 30, 45, 60, 75} -- AI updates
		EEex_LuaDecode_Object.m_curAction.m_specificID = reevaluationPeriod[math.random(#reevaluationPeriod)]
	end
	--
	return toReturn -- CGameSprite
end

