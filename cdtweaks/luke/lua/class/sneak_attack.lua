--[[
+----------------------------------------------------------------------------------+
| cdtweaks, NWN-ish Sneak Attack / Crippling Strike class feat for Rogues/Stalkers |
+----------------------------------------------------------------------------------+
--]]

-- at most once per round (unless ASSASSINATE=1) --

EEex_Sprite_AddBlockWeaponHitListener(function(args)

	local weapon = args.weapon -- CItem
	local weaponHeader = weapon.pRes.pHeader -- Item_Header_st
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	local weaponAbility = args.weaponAbility -- Item_ability_st

	local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtRogueSneakAttackTimer","LOCALS")')
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")

	if EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_options.m_b3ESneakAttack == 1 then

		if weaponAbility.type == 1 then -- melee

			if EEex_IsBitUnset(weaponHeader.notUsableBy, 22) then -- if usable by single-class thieves

				if attackingSprite:getActiveStats().m_nAssassinate == 0 then

					if not conditionalString:evalConditionalAsAIBase(attackingSprite) then

						targetSprite:applyEffect({
							["effectID"] = 0x124, -- Immunity to backstab (292)
							["dwFlags"] = 1,
							["sourceID"] = targetSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
							["noSave"] = true, -- just in case...?
						})

					else

						-- make the AI less "cheaty": if the targeted creature is attacking the enemy rogue with a melee weapon and is not helpless, block the incoming sneak attack
						if attackingSprite.m_typeAI.m_EnemyAlly > 200 then -- if [EVILCUTOFF]

							if (targetSprite.m_targetId == attackingSprite.m_id) and not (isWeaponRanged:evalConditionalAsAIBase(targetSprite)) and EEex_BAnd(targetSprite:getActiveStats().m_generalState, 0x100029) == 0 then

								targetSprite:applyEffect({
									["effectID"] = 0x124, -- Immunity to backstab (292)
									["dwFlags"] = 1,
									["sourceID"] = targetSprite.m_id,
									["sourceTarget"] = targetSprite.m_id,
									["noSave"] = true, -- just in case...?
								})

							end

						end

					end

				end

			end

		end

	end

	conditionalString:free()
	isWeaponRanged:free()

end)

-- crippling strike (assassins: paralysis; stalkers: silence; others: -2 STR) --

function %ROGUE_SNEAK_ATTACK%(CGameEffect, CGameSprite)

	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)

	local isImmuneToSilence = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,38)")
	local isImmuneToParalysis = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,109)")

	-- max 1 sneak attack per round if not ASSASSINATE=1
	local responseString = EEex_Action_ParseResponseString('SetGlobalTimer("gtRogueSneakAttackTimer","LOCALS",6)')
	if sourceSprite:getActiveStats().m_nAssassinate == 0 then
		responseString:executeResponseAsAIBaseInstantly(sourceSprite)
	end

	-- crippling strike (assassins: paralysis; stalkers: silence; others: -2 str)
	if CGameEffect.m_effectAmount > 0 then

		local sourceKitStr = GT_Resource_IDSToSymbol["kit"][sourceSprite:getActiveStats().m_nKit]
		local effectCodes = {}
		local roll = Infinity_RandomNumber(CGameEffect.m_effectAmount, CGameEffect.m_effectAmount * 6)

		if sourceKitStr == "ASSASIN" then -- typo in "kit.ids" file

			if not isImmuneToParalysis:evalConditionalAsAIBase(CGameSprite) then
				effectCodes = {
					{["op"] = 0x6D, ["p2"] = 2, ["dur"] = 6 * roll, ["effsource"] = "%ROGUE_SNEAK_ATTACK%B"}, -- Paralyze (109) (EA=ANYONE)
					{["op"] = 0x8E, ["p2"] = 13, ["dur"] = 6 * roll, ["effsource"] = "%ROGUE_SNEAK_ATTACK%B"} -- Display portrait icon (142): held
					{["op"] = 0x8B, ["p1"] = %feedback_strref_paralyzed%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%B"} -- Display string (139): paralyzed
					{["op"] = 0xCE, ["res"] = "%ROGUE_SNEAK_ATTACK%B", ["p1"] = %feedback_strref_already_paralyzed%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%B", ["dur"] = 6 * roll}, -- Protection from spell (206) (already paralyzed)
				}
			else
				effectCodes = {
					{["op"] = 0x8B, ["p1"] = %feedback_strref_immune%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%B"} -- Display string (139): unaffected by effects from crippling strike
				}
			end

		elseif sourceKitStr == "STALKER" then

			if not isImmuneToSilence:evalConditionalAsAIBase(CGameSprite) then
				effectCodes = {
					{["op"] = 0x26, ["dur"] = 6 * roll, ["effsource"] = "%ROGUE_SNEAK_ATTACK%C"}, -- Silence (38)
					{["op"] = 0x8E, ["p2"] = 34, ["dur"] = 6 * roll, ["effsource"] = "%ROGUE_SNEAK_ATTACK%C"} -- Display portrait icon (142): silenced
					{["op"] = 0x8B, ["p1"] = %feedback_strref_silenced%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%C"} -- Display string (139): silenced
					{["op"] = 0xCE, ["res"] = "%ROGUE_SNEAK_ATTACK%C", ["p1"] = %feedback_strref_already_silenced%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%C", ["dur"] = 6 * roll}, -- Protection from spell (206) (already silenced)
				}
			else
				effectCodes = {
					{["op"] = 0x8B, ["p1"] = %feedback_strref_immune%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%C"} -- Display string (139): unaffected by effects from crippling strike
				}
			end

		else

			local targetSTR = CGameSprite:getActiveStats().m_nSTR

			if targetSTR > 1 then
				effectCodes = {
					{["op"] = 0x2C, ["p1"] = targetSTR > 2 and -2 or -1, ["dur"] = 6 * roll, ["effsource"] = "%ROGUE_SNEAK_ATTACK%D"}, -- Strength bonus (44)
					{["op"] = 0x8B, ["p1"] = %feedback_strref_str_mod%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%D"} -- Display string (139): str modification
				}
			else
				effectCodes = {
					{["op"] = 0x8B, ["p1"] = %feedback_strref_immune%, ["effsource"] = "%ROGUE_SNEAK_ATTACK%D"} -- Display string (139): unaffected by effects from crippling strike
				}
			end

		end

		-- apply effects
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["duration"] = attributes["dur"] or 0,
				["savingThrow"] = 0x4, -- save vs. death
				["saveMod"] = -1 * (CGameEffect.m_effectAmount - 1),
				["res"] = attributes["res"] or "",
				["m_sourceRes"] = attributes["effsource"] or "",
				["m_sourceType"] = 1, -- spl
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end

	end

	responseString:free()
	isImmuneToParalysis:free()
	isImmuneToSilence:free()

end
