--[[
+------------------------------------------------------------------------------------+
| cdtweaks, NWN-style Sneak Attack / Crippling Strike class feat for Rogues/Stalkers |
+------------------------------------------------------------------------------------+
--]]

-- Apply Ability (Epic Sneak Attack) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNEpicSneakAttack", 1)
	end
	-- Check creature's class / flags
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- any lvl 30+ assassin (single/multi/(complete)dual)
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	local isAssassin = spriteKitStr == "ASSASIN" -- typo in KIT.IDS / KITLIST.2DA
	--
	local conditionalString = "ClassLevelGT(Myself,ROGUE,29)"
	--
	local applyAbility = isThiefAll and isAssassin and GT_EvalConditional["parseConditionalString"](sprite, nil, conditionalString)
	--
	if sprite:getLocalInt("gtNWNEpicSneakAttack") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNEpicSneakAttack", 0)
		end
	end
end)

-- at most once per round (unless ASSASSINATE=1) --

EEex_Sprite_AddBlockWeaponHitListener(function(args)

	local weapon = args.weapon -- CItem
	local weaponHeader = weapon.pRes.pHeader -- Item_Header_st
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	local weaponAbility = args.weaponAbility -- Item_ability_st

	local aux = EEex_GetUDAux(attackingSprite)

	local conditionalString = '!GlobalTimerNotExpired("gtNWNSneakAttRogueTimer","LOCALS")'
	--local targetSelectedWeapon = GT_Sprite_GetSelectedWeapon(targetSprite)

	if EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_options.m_b3ESneakAttack == 1 then

		if weaponAbility.type == 1 then -- melee

			if EEex_IsBitUnset(weaponHeader.notUsableBy, 22) then -- if usable by single-class thieves

				if attackingSprite:getActiveStats().m_nAssassinate == 0 then

					if not GT_EvalConditional["parseConditionalString"](attackingSprite, nil, conditionalString) then

						targetSprite:applyEffect({
							["effectID"] = 0x124, -- Immunity to backstab (292)
							["dwFlags"] = 1,
							["sourceID"] = targetSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
							["noSave"] = true, -- just in case...?
						})

					else

						-- make the AI less "cheaty": if the targeted creature is attacking the enemy rogue and is not helpless, block the incoming sneak attack
						if attackingSprite.m_typeAI.m_EnemyAlly > 200 then -- if [EVILCUTOFF]

							if (targetSprite.m_targetId == attackingSprite.m_id) and EEex_BAnd(targetSprite:getActiveStats().m_generalState, 0x100029) == 0 then

								targetSprite:applyEffect({
									["effectID"] = 0x124, -- Immunity to backstab (292)
									["dwFlags"] = 1,
									["sourceID"] = targetSprite.m_id,
									["sourceTarget"] = targetSprite.m_id,
									["noSave"] = true, -- just in case...?
								})

								--
								goto continue

							end

						end

						-- Epic Sneak Attack
						if attackingSprite:getLocalInt("gtNWNEpicSneakAttack") == 1 and targetSprite:getActiveStats().m_bImmunityToBackStab > 0 then

							targetSprite:applyEffect({
								["effectID"] = 0x124, -- Immunity to backstab (292)
								["dwFlags"] = 0,
								["sourceID"] = attackingSprite.m_id,
								["sourceTarget"] = targetSprite.m_id,
								["noSave"] = true, -- just in case...?
							})

							-- mark this attack as 'bypass sneak attack immunity'
							aux["gt_NWN_EpicSneakAttack_BypassOp292"] = true

						end

					end

				else

					-- Epic Sneak Attack
					if attackingSprite:getLocalInt("gtNWNEpicSneakAttack") == 1 and targetSprite:getActiveStats().m_bImmunityToBackStab > 0 then

						targetSprite:applyEffect({
							["effectID"] = 0x124, -- Immunity to backstab (292)
							["dwFlags"] = 0,
							["sourceID"] = attackingSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
							["noSave"] = true, -- just in case...?
						})

						-- mark this attack as 'bypass sneak attack immunity'
						aux["gt_NWN_EpicSneakAttack_BypassOp292"] = true

					end

				end

			end

		end

	end

	::continue::

end)

-- Epic Sneak Attack: Sneak Attacks will deliver half damage against creatures normally immune to them (Barbarians will still be fully immune... That's a hardcoded feature of their kit...) --

EEex_Sprite_AddAlterBaseWeaponDamageListener(function(context)
	local effect = context.effect -- CGameEffect
	local attacker = context.attacker -- CGameSprite
	local target = context.target -- CGameSprite

	local aux = EEex_GetUDAux(attacker)

	local damageAmount = effect.m_effectAmount

	if aux["gt_NWN_EpicSneakAttack_BypassOp292"] then

		aux["gt_NWN_EpicSneakAttack_BypassOp292"] = nil

		if attacker.m_typeAI.m_EnemyAlly > 30 or (GT_Sprite_IsFlanking(attacker.m_nDirection, target.m_nDirection) or attacker:getActiveStats().m_nAssassinate > 0) then -- [GOODCUTOFF]: check if the attacker is flanking its target

			if effect.m_effectId == 0xC and effect.m_slotNum == -1 and effect.m_sourceType == 0 and effect.m_sourceRes:get() == "" then -- base weapon damage

				effect.m_effectAmount = math.floor(damageAmount / 2)

			end

		end

	end
end)

-- crippling strike (assassins: paralysis; stalkers: silence; others: -2 STR) --

function %ROGUE_SNEAK_ATTACK%(CGameEffect, CGameSprite)

	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)

	local isImmuneToSilence = "EEex_IsImmuneToOpcode(Myself,38)"
	local isImmuneToParalysis = "EEex_IsImmuneToOpcode(Myself,109)"

	-- max 1 sneak attack per round if not ASSASSINATE=1
	local responseString = 'SetGlobalTimer("gtNWNSneakAttRogueTimer","LOCALS",6)'
	if sourceSprite:getActiveStats().m_nAssassinate == 0 then
		GT_ExecuteResponse["parseResponseString"](sourceSprite, nil, responseString)
	end

	-- crippling strike (assassins: paralysis; stalkers: silence; others: -2 str)
	if CGameEffect.m_effectAmount > 0 then

		local sourceKitStr = EEex_Resource_KitIDSToSymbol(sourceSprite:getActiveStats().m_nKit)
		local effectCodes = {}
		local roll = Infinity_RandomNumber(CGameEffect.m_effectAmount, CGameEffect.m_effectAmount * 6)

		if sourceKitStr == "ASSASIN" then -- typo in "kit.ids" file

			if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, isImmuneToParalysis) then
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

			if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, isImmuneToSilence) then
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

end
