--[[
+-----------------------------------------------------------+
| cdtweaks, NWN-ish Parry mode for Blades and Swashbucklers |
+-----------------------------------------------------------+
--]]

-- Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or GT_Globals_IsChargenOrStartMenu[Infinity_GetCurrentScreenName()] then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNParry", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / kit
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- any thief (swashbuckler) (single/multi/(complete)dual) or bard (blade)
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	local isBardAll = GT_Sprite_CheckIDS(sprite, class["BARD_ALL"], 5)
	local isSwashbuckler = spriteKitStr == "SWASHBUCKLER"
	local isBlade = spriteKitStr == "BLADE"
	--
	local gainAbility = (isBardAll and isBlade) or (isThiefAll and isSwashbuckler)
	--
	if sprite:getLocalInt("gtNWNParry") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNParry", 0)
			--
			if EEex_Sprite_GetLocalInt(sprite, "gtNWNParryMode") == 1 then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%BLADE_SWASHBUCKLER_PARRY%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- save vs. breath to parry an incoming attack; the higher DEX, the easier is to succeed --

EEex_Sprite_AddBlockWeaponHitListener(function(args)
	local toReturn = false
	--
	local attacksPerRound = {0, 1, 2, 3, 4, 5, .5, 1.5, 2.5, 3.5, 4.5}
	local attacksPerRoundHaste = {0, 2, 4, 6, 8, 10, 1, 3, 5, 7, 9}
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--local state = GT_Resource_SymbolToIDS["state"]
	--
	local dexmod = GT_Resource_2DA["dexmod"]
	--
	local attackingWeapon = args.weapon -- CItem
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	local attackingWeaponAbility = args.weaponAbility -- Item_ability_st
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(targetSprite)
	-- you cannot parry weapons with bare hands (only other bare hands)
	local targetSelectedWeapon = GT_Sprite_GetSelectedWeapon(targetSprite)
	--
	local aux = EEex_GetUDAux(targetSprite)
	--
	local attackingEquipment = attackingSprite.m_equipment -- CGameSpriteEquipment
	-- get # attacks
	local targetNumberOfAttacks
	if EEex_IsBitSet(targetActiveStats.m_generalState, 15) then -- if STATE_HASTED
		targetNumberOfAttacks = attacksPerRoundHaste[EEex_Sprite_GetStat(targetSprite, stats["NUMBEROFATTACKS"]) + 1]
	else
		targetNumberOfAttacks = Infinity_RandomNumber(1, 2) == 1 and math.ceil(attacksPerRound[EEex_Sprite_GetStat(targetSprite, stats["NUMBEROFATTACKS"]) + 1]) or math.floor(attacksPerRound[EEex_Sprite_GetStat(targetSprite, stats["NUMBEROFATTACKS"]) + 1])
	end
	--
	local modifier = tonumber(dexmod[string.format("%s", targetActiveStats.m_nDEX)]["AC"])
	--local roll = targetSprite.m_saveVSBreathRoll
	local roll = Infinity_RandomNumber(1, 20) -- 1d20
	local success = false
	--
	if roll == 20 then -- natural 20
		success = true
		modifier = 0
	elseif roll == 1 then -- natural 1
		modifier = 0
	else
		success = (targetActiveStats.m_nSaveVSBreath + modifier <= roll) -- [!] according to "dexmod.2da", the greater the DEX, the lower is the modifier, so we need to subtract it from the roll
	end
	--targetSprite:setStoredScriptingTarget("GT_ParryModeTarget", attackingSprite)
	--local conditionalString = EEex_Trigger_ParseConditionalString('OR(2) \n !Allegiance(Myself,GOODCUTOFF) InWeaponRange(EEex_Target("GT_ParryModeTarget") \n OR(2) \n !Allegiance(Myself,EVILCUTOFF) Range(EEex_Target("GT_ParryModeTarget"),4)') -- we intentionally let the AI cheat. In so doing, it can enter the mode without worrying about being in weapon range...
	--
	if targetSprite:getLocalInt("gtNWNParryMode") == 1 then -- parry mode ON
		--
		if targetSprite.m_curAction.m_actionID == 0 and targetSprite.m_nSequence == 7 then -- idle/ready (in particular, you cannot parry while performing a riposte attack)
			--if EEex_BAnd(targetActiveStats.m_generalState, state["CD_STATE_NOTVALID"]) == 0 then -- incapacitated creatures cannot parry
			if EEex_BAnd(targetActiveStats.m_generalState, 0x100029) == 0 then -- incapacitated creatures cannot parry
				--
				if EEex_Sprite_GetStat(targetSprite, stats["GT_NUMBER_OF_ATTACKS_PARRIED"]) < targetNumberOfAttacks then -- you can parry at most X number of attacks per round, where X is the number of attacks of the parrying creature
					--
					if attackingWeaponAbility.type == 1 and attackingWeaponAbility.range <= 2 then -- only melee attacks can be parried
						--
						if targetSelectedWeapon["slot"] ~= 10 or attackingEquipment.m_selectedWeapon == 10 then -- bare hands can only parry bare hands
							--
							if success then
								-- display feedback message
								GT_Sprite_DisplayMessage(targetSprite,
									string.format("%s : %d %s %d = %d : %s",
										Infinity_FetchString(%feedback_strref_parry%), roll, modifier < 0 and "+" or "-", math.abs(modifier), roll - modifier, Infinity_FetchString(%feedback_strref_success%)),
									0x1889A1
								)
								-- increment stats["GT_NUMBER_OF_ATTACKS_PARRIED"] by 1; reset to 0 after one round
								local effectCodes = {
									{["op"] = 401, ["p1"] = 1, ["spec"] = stats["GT_NUMBER_OF_ATTACKS_PARRIED"], ["tmg"] = 1, ["effsource"] = "%BLADE_SWASHBUCKLER_PARRY%C"}, -- EEex: Set Extended Stat
									{["op"] = 321, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%C", ["tmg"] = 4, ["dur"] = 6, ["effsource"] = "%BLADE_SWASHBUCKLER_PARRY%D"}, -- Remove effects by resource
									{["op"] = 318, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%D", ["dur"] = 6, ["effsource"] = "%BLADE_SWASHBUCKLER_PARRY%D"}, -- Protection from resource
								}
								--
								for _, attributes in ipairs(effectCodes) do
									targetSprite:applyEffect({
										["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
										["effectAmount"] = attributes["p1"] or 0,
										["special"] = attributes["spec"] or 0,
										["res"] = attributes["res"] or "",
										["durationType"] = attributes["tmg"] or 0,
										["duration"] = attributes["dur"] or 0,
										["m_sourceRes"] = attributes["effsource"] or "",
										["sourceID"] = targetSprite.m_id,
										["sourceTarget"] = targetSprite.m_id,
									})
								end
								-- initialize the attack frame counter
								targetSprite.m_attackFrame = 0
								-- store attacking ID
								aux["gt_NWN_Parry_AttackerID"] = attackingSprite.m_id
								-- cast a dummy spl that performs the attack animation via op138 (p2=0)
								attackingSprite:applyEffect({
									["effectID"] = 146, -- Cast spl
									["res"] = "%BLADE_SWASHBUCKLER_PARRY%E",
									["sourceID"] = targetSprite.m_id,
									["sourceTarget"] = attackingSprite.m_id,
								})
								-- block base weapon damage + on-hit effects (if any)
								toReturn = true
							else
								GT_Sprite_DisplayMessage(targetSprite,
									string.format("%s : %d %s %d = %d : %s",
										Infinity_FetchString(%feedback_strref_parry%), roll, modifier < 0 and "+" or "-", math.abs(modifier), roll - modifier, Infinity_FetchString(%feedback_strref_fail%)),
									0x1889A1
								)
							end
						end
					end
				end
			end
		end
	end
	--
	--conditionalString:free()
	--
	return toReturn
end)

-- cast a spl (riposte attack) when ``m_attackFrame`` is equal to 6 (that should be approx. the value corresponding to the weapon hit...?) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local aux = EEex_GetUDAux(sprite)
	-- if the blade / swashbuckler gets hit while performing a riposte attack, the attack will be canceled
	if sprite:getLocalInt("gtNWNParryMode") == 1 and sprite.m_attackFrame == 6 and sprite.m_nSequence == 0 then
		local attackingSprite = EEex_GameObject_Get(aux["gt_NWN_Parry_AttackerID"])
		--
		if attackingSprite then
			attackingSprite:applyEffect({
				["effectID"] = 146, -- Cast spl
				["dwFlags"] = 1, -- mode: instant / permanent
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%F",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = attackingSprite.m_id,
			})
		end
	end
end)

-- automatically cancel mode if ranged weapon / polymorphed / magically created weapon --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	--
	if sprite:getLocalInt("gtNWNParry") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtNWNParryMode") == 1 then -- if in parry mode...
			if selectedWeapon["ability"].type ~= 1 or sprite.m_derivedStats.m_bPolymorphed == 1 or selectedWeapon["slot"] == 34 then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%BLADE_SWASHBUCKLER_PARRY%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- maintain SEQ_READY while in parry mode --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	if sprite:getLocalInt("gtNWNParry") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtNWNParryMode") == 1 and sprite.m_nSequence == 6 and sprite.m_curAction.m_actionID == 0 then
			sprite:applyEffect({
				["effectID"] = 146, -- Cast spell
				["res"] = "%BLADE_SWASHBUCKLER_PARRY%G",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- make sure it cannot be disrupted. Cancel mode if no longer idle --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("gtNWNParry") == 1 then
		--
		local toskip = {
			["%BLADE_SWASHBUCKLER_PARRY%E"] = true,
			["%BLADE_SWASHBUCKLER_PARRY%G"] = true,
		}
		--
		if EEex_Sprite_GetLocalInt(sprite, "gtNWNParryMode") == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%BLADE_SWASHBUCKLER_PARRY%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		else
			if not (action.m_actionID == 113 and toskip[action.m_string1.m_pchData:get()]) then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%BLADE_SWASHBUCKLER_PARRY%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- core op402 listener --

function %BLADE_SWASHBUCKLER_PARRY%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 0 then
		-- we apply effects here due to op232's presence (which for best results requires EFF V2.0)
		local effectCodes = {
			{["op"] = 321, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%"}, -- remove effects by resource
			{["op"] = 232, ["p2"] = 16, ["res"] = "%BLADE_SWASHBUCKLER_PARRY%B", ["tmg"] = 1}, -- cast spl on condition (condition: Die(); target: self)
			{["op"] = 142, ["p2"] = %feedback_icon%, ["tmg"] = 1}, -- feedback icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["durationType"] = attributes["tmg"] or 0,
				["m_sourceRes"] = "%BLADE_SWASHBUCKLER_PARRY%",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtNWNParryMode", 1)
	elseif CGameEffect.m_effectAmount == 1 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%BLADE_SWASHBUCKLER_PARRY%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		--
		EEex_Sprite_SetLocalInt(CGameSprite, "gtNWNParryMode", 0)
	elseif CGameEffect.m_effectAmount == 2 then
		local itemflag = GT_Resource_SymbolToIDS["itemflag"]
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
		--
		local strmod = GT_Resource_2DA["strmod"]
		local strmodex = GT_Resource_2DA["strmodex"]
		--
		local strBonus = tonumber(strmod[string.format("%s", sourceActiveStats.m_nSTR)]["DAMAGE"])
		local strExtraBonus = sourceActiveStats.m_nSTR == 18 and tonumber(strmodex[string.format("%s", sourceActiveStats.m_nSTRExtra)]["DAMAGE"]) or 0
		local damageBonus = sourceActiveStats.m_nDamageBonus -- op73
		local wspecial = sourceActiveStats.m_DamageBonusRight -- wspecial.2da
		local meleeDamageBonus = sourceActiveStats.m_nMeleeDamageBonus -- op285 (STAT 167)
		-- op120
		local conditionalString = 'WeaponEffectiveVs(EEex_Target("gtParryTarget"),MAINHAND)'
		--
		if EEex_BAnd(selectedWeapon["header"].itemFlags, itemflag["TWOHANDED"]) == 0 and Infinity_RandomNumber(1, 2) == 1 then -- if single-handed and 1d2 == 1 (50% chance)
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand then -- sanity check
				local pHeader = offHand.pRes.pHeader -- Item_Header_st
				if EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType) ~= "SHIELD" then -- if not shield, then overwrite item resref / header / ability...
					selectedWeapon["resref"] = offHand.pRes.resref:get()
					selectedWeapon["header"] = pHeader -- Item_Header_st
					selectedWeapon["ability"] = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
					--
					wspecial = sourceActiveStats.m_DamageBonusLeft -- wspecial.2da
					--
					conditionalString = 'WeaponEffectiveVs(EEex_Target("gtParryTarget"),OFFHAND)'
				end
			end
		end
		--
		local modifier = strBonus + strExtraBonus + damageBonus + wspecial + meleeDamageBonus
		-- collect on-hit effects (if any)
		local onHitEffects = {}
		do
			local currentEffectAddress = EEex_UDToPtr(selectedWeapon["header"]) + selectedWeapon["header"].effectsOffset + selectedWeapon["ability"].startingEffect * Item_effect_st.sizeof
			--
			for idx = 1, selectedWeapon["ability"].effectCount do
				local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
				--
				table.insert(onHitEffects, {
					["effectID"] = pEffect.effectID,
					["targetType"] = pEffect.targetType,
					["spellLevel"] = pEffect.spellLevel,
					["effectAmount"] = pEffect.effectAmount,
					["dwFlags"] = pEffect.dwFlags,
					["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
					["m_flags"] = EEex_RShift(pEffect.durationType, 8),
					["duration"] = pEffect.duration,
					["probabilityUpper"] = pEffect.probabilityUpper,
					["probabilityLower"] = pEffect.probabilityLower,
					["res"] = pEffect.res:get(),
					["numDice"] = pEffect.numDice,
					["diceSize"] = pEffect.diceSize,
					["savingThrow"] = pEffect.savingThrow,
					["saveMod"] = pEffect.saveMod,
					["special"] = pEffect.special,
				})
				--
				currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
			end
		end
		--
		local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
		--
		if GT_EvalConditional["parseConditionalString"](sourceSprite, CGameSprite, conditionalString, "gtParryTarget") then
			-- damage type ``NONE`` requires extra care
			local mode = 0 -- normal
			if selectedWeapon["ability"].damageType == 0 and selectedWeapon["ability"].damageDiceCount > 0 then
				mode = 1 -- set HP to value
			end
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0xC, -- Damage (12)
				["dwFlags"] = damageTypeIDS * 0x10000 + mode,
				["effectAmount"] = (selectedWeapon["ability"].damageDiceCount == 0 and selectedWeapon["ability"].damageDice == 0 and selectedWeapon["ability"].damageDiceBonus == 0) and 0 or (selectedWeapon["ability"].damageDiceBonus + modifier),
				["numDice"] = selectedWeapon["ability"].damageDiceCount,
				["diceSize"] = selectedWeapon["ability"].damageDice,
				--["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				--["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			-- apply on-hit effects (if any)
			for _, effect in ipairs(onHitEffects) do
				local array = {}
				--
				if effect["targetType"] == 1 or effect["targetType"] == 9 then -- self / original caster
					table.insert(array, sourceSprite)
				elseif effect["targetType"] == 2 then -- projectile target
					table.insert(array, CGameSprite)
				elseif effect["targetType"] == 3 or (effect["targetType"] == 6 and sourceSprite.m_typeAI.m_EnemyAlly == 2) then -- party
					for i = 0, 5 do
						local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
						if partyMember and EEex_BAnd(partyMember:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, partyMember)
						end
					end
				elseif effect["targetType"] == 4 then -- everyone
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, itrSprite in ipairs(everyone) do
						if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, itrSprite)
						end
					end
				elseif effect["targetType"] == 5 then -- everyone but party
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, itrSprite in ipairs(everyone) do
						if itrSprite.m_typeAI.m_EnemyAlly ~= 2 then
							if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, itrSprite)
							end
						end
					end
				elseif effect["targetType"] == 6 then -- caster group
					local casterGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", sourceSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
					--
					for _, itrSprite in ipairs(casterGroup) do
						if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, itrSprite)
						end
					end
				elseif effect["targetType"] == 7 then -- target group
					local targetGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", CGameSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
					--
					for _, itrSprite in ipairs(targetGroup) do
						if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
							table.insert(array, itrSprite)
						end
					end
				elseif effect["targetType"] == 8 then -- everyone but self
					local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
					--
					for _, itrSprite in ipairs(everyone) do
						if itrSprite.m_id ~= sourceSprite.m_id then
							if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, itrSprite)
							end
						end
					end
				end
				--
				for _, object in ipairs(array) do
					EEex_GameObject_ApplyEffect(object,
					{
						["effectID"] = effect["effectID"],
						["spellLevel"] = effect["spellLevel"],
						["effectAmount"] = effect["effectAmount"],
						["dwFlags"] = effect["dwFlags"],
						["durationType"] = effect["durationType"],
						["m_flags"] = effect["m_flags"],
						["duration"] = effect["duration"],
						["probabilityUpper"] = effect["probabilityUpper"],
						["probabilityLower"] = effect["probabilityLower"],
						["res"] = effect["res"],
						["numDice"] = effect["numDice"],
						["diceSize"] = effect["diceSize"],
						["savingThrow"] = effect["savingThrow"],
						["saveMod"] = effect["saveMod"],
						["special"] = effect["special"],
						--
						["m_school"] = selectedWeapon["ability"].school,
						["m_secondaryType"] = selectedWeapon["ability"].secondaryType,
						--
						["m_sourceRes"] = selectedWeapon["resref"],
						["m_sourceType"] = 2,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			end
		else
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display string
				["effectAmount"] = %feedback_strref_weapon_ineffective%,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
