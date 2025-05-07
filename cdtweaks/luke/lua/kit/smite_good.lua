--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Smite Good class feat for Blackguards |
+---------------------------------------------------------+
--]]

-- Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or Infinity_GetCurrentScreenName() == 'CHARGEN' then
		return
	end
	-- internal function that grants the ability
	local gain = function(int, flag)
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNSmiteGood", int)
		-- Get how many instances are currently memorized
		local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
		local memList = spellLevelMemListArray:getReference(0) -- *count starts from 0*
		local memorized = 0
		--
		EEex_Utility_IterateCPtrList(memList, function(memInstance)
			local memInstanceResref = memInstance.m_spellId:get()
			if memInstanceResref == "%BLACKGUARD_SMITE_GOOD%" then
				local memFlags = memInstance.m_flags
				if EEex_IsBitSet(memFlags, 0x0) then
					memorized = memorized + 1
				end
			end
		end)
		--
		sprite:applyEffect({
			["effectID"] = 172, -- remove spell
			["res"] = "%BLACKGUARD_SMITE_GOOD%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--
		for i = 1, int do
			sprite:applyEffect({
				["effectID"] = 171, -- give spell
				["res"] = "%BLACKGUARD_SMITE_GOOD%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
		--
		if flag then -- unmemorize new instances (i.e., force the player to rest)
			local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
			local memList = spellLevelMemListArray:getReference(0) -- *count starts from 0*
			--
			EEex_Utility_IterateCPtrList(memList, function(memInstance)
				local memInstanceResref = memInstance.m_spellId:get()
				if memInstanceResref == "%BLACKGUARD_SMITE_GOOD%" then
					local memFlags = memInstance.m_flags
					if EEex_IsBitSet(memFlags, 0x0) then
						if memorized < int then
							memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0)
						end
						memorized = memorized + 1
					end
				end
			end)
		end
	end
	-- Check creature's class / kit
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	--
	local gainAbility = spriteClassStr == "PALADIN" and spriteKitStr == "Blackguard" and EEex_IsBitUnset(spriteFlags, 0x9)
	-- One use per 5 levels (starting from level 1)
	local usesPerDay = math.floor(spriteLevel1 / 5) + 1
	--
	if sprite:getLocalInt("gtNWNSmiteGood") == 0 then
		if gainAbility then
			gain(usesPerDay, false)
		end
	else
		if gainAbility then
			-- Check if level has changed since last application
			if usesPerDay ~= sprite:getLocalInt("gtNWNSmiteGood") then
				gain(usesPerDay, true)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNSmiteGood", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%BLACKGUARD_SMITE_GOOD%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Check if ranged weapon / fist / magically created weapon equipped --

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)
	local curAction = sprite.m_curAction
	local spriteAux = EEex_GetUDAux(sprite)

	if not (curAction.m_actionID == 31 and resref == "%BLACKGUARD_SMITE_GOOD%" and changeAmount < 0) then
		return
	end

	-- recast as ``ForceSpell()`` (so as to prevent spell disruption) --
	curAction.m_actionID = 113

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
	local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- *count starts from 0*

	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")

	local equipment = sprite.m_equipment -- CGameSpriteEquipment

	-- restore memorization bit (in case of invalid weapon)
	if equipment.m_selectedWeapon == 10 or equipment.m_selectedWeapon == 34 or isWeaponRanged:evalConditionalAsAIBase(sprite) then

		EEex_Utility_IterateCPtrList(memList, function(memInstance)
			local memInstanceResref = memInstance.m_spellId:get()
			if memInstanceResref == resref then
				local memFlags = memInstance.m_flags
				if EEex_IsBitUnset(memFlags, 0x0) then
					memInstance.m_flags = EEex_SetBit(memFlags, 0x0)
					return true
				end
			end
		end)

		sprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_invalid_weapon%,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})

	else

		-- store target id
		spriteAux["gtSmiteGoodTargetID"] = curAction.m_acteeID.m_Instance

		-- initialize the attack frame counter
		sprite.m_attackFrame = 0

	end

	isWeaponRanged:free()
end)

-- Forget about ``spriteAux["gtSmiteGoodTargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtNWNSmiteGood") > 0 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%BLACKGUARD_SMITE_GOOD%") then
			if spriteAux["gtSmiteGoodTargetID"] ~= nil then
				spriteAux["gtSmiteGoodTargetID"] = nil
			end
		end
	end
end)

-- cast the actual spl (i.e. Smite Good) when ``m_attackFrame`` is equal to 6 (that should be approx. the value corresponding to the weapon hit...?) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	local equipment = sprite.m_equipment -- CGameSpriteEquipment
	--
	if sprite:getLocalInt("gtNWNSmiteGood") > 0 then
		if not (equipment.m_selectedWeapon == 10 or equipment.m_selectedWeapon == 34 or isWeaponRanged:evalConditionalAsAIBase(sprite)) then
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gtSmiteGoodTargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gtSmiteGoodTargetID"])
					spriteAux["gtSmiteGoodTargetID"] = nil
					--
					targetSprite:applyEffect({
						["effectID"] = 402, -- invoke lua
						["res"] = "%BLACKGUARD_SMITE_GOOD%",
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
				end
			end
		end
	end
	--
	isWeaponRanged:free()
end)

-- core op402 listener --

function %BLACKGUARD_SMITE_GOOD%(CGameEffect, CGameSprite)
	-- Fetch components of check
	local roll = Infinity_RandomNumber(1, 20) -- 1d20
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
	--
	local gtabmod = GT_Resource_2DA["gtabmod"]
	local chrBonus = tonumber(gtabmod[string.format("%s", sourceActiveStats.m_nCHR)]["BONUS"])
	--
	local thac0 = sourceActiveStats.m_nTHAC0 -- base thac0 (STAT 7)
	local thac0BonusRight = sourceActiveStats.m_THAC0BonusRight -- this should include the bonus from the weapon + str + wspecial.2da
	local meleeTHAC0Bonus = sourceActiveStats.m_nMeleeTHAC0Bonus -- op284 (STAT 166)
	-- collect on-hit effects (if any)
	local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local selectedWeaponResRef = selectedWeapon.pRes.resref:get()
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local op12DamageType, ACModifier = GT_Utility_DamageTypeConverter(selectedWeaponAbility.damageType, targetActiveStats)
	--
	local onHitEffects = {}
	do
		local currentEffectAddress = EEex_UDToPtr(selectedWeaponHeader) + selectedWeaponHeader.effectsOffset + selectedWeaponAbility.startingEffect * Item_effect_st.sizeof
		--
		for idx = 1, selectedWeaponAbility.effectCount do
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
	-- op120
	sourceSprite:setStoredScriptingTarget("GT_ScriptingTarget_SmiteGood", CGameSprite)
	local weaponEffectiveVs = EEex_Trigger_ParseConditionalString('WeaponEffectiveVs(EEex_Target("GT_ScriptingTarget_SmiteGood"),MAINHAND)')
	--
	local isGood = EEex_Trigger_ParseConditionalString('Alignment(Myself,MASK_GOOD)')
	--
	if weaponEffectiveVs:evalConditionalAsAIBase(sourceSprite) then
		if isGood:evalConditionalAsAIBase(CGameSprite) then
			-- compute attack roll (simplified for the time being... it doesn't consider attack of opportunity, invisibility, luck, op178, op301, op362, &c.)
			local success = false
			local modifier = thac0BonusRight + meleeTHAC0Bonus + chrBonus
			--
			if roll == 20 then -- automatic hit
				success = true
				modifier = 0
			elseif roll == 1 then -- automatic miss (critical failure)
				modifier = 0
			elseif roll + modifier >= thac0 - (targetActiveStats.m_nArmorClass + ACModifier) then
				success = true
			end
			--
			if success then
				-- display feedback message
				GT_Utility_DisplaySpriteMessage(sourceSprite,
					string.format("%s : %d + %d = %d : %s",
						Infinity_FetchString(%feedback_strref_smite_good%), roll, modifier, roll + modifier, Infinity_FetchString(%feedback_strref_hit%)),
					0x915D48, 0x915D48 -- Chrome Blue
				)
				--
				local strmod = GT_Resource_2DA["strmod"]
				local strmodex = GT_Resource_2DA["strmodex"]
				--
				local strBonus = tonumber(strmod[string.format("%s", sourceActiveStats.m_nSTR)]["DAMAGE"])
				local strExtraBonus = sourceActiveStats.m_nSTR == 18 and tonumber(strmodex[string.format("%s", sourceActiveStats.m_nSTRExtra)]["DAMAGE"]) or 0
				local damageBonus = sourceActiveStats.m_nDamageBonus -- op73
				local damageBonusRight = sourceActiveStats.m_DamageBonusRight -- wspecial.2da
				local meleeDamageBonus = sourceActiveStats.m_nMeleeDamageBonus -- op285 (STAT 167)
				--
				local modifier = strBonus + strExtraBonus + damageBonus + damageBonusRight + meleeDamageBonus + sourceActiveStats.m_nLevel1
				-- damage type ``NONE`` requires extra care
				local mode = 0 -- normal
				if selectedWeaponAbility.damageType == 0 and selectedWeaponAbility.damageDiceCount > 0 then
					mode = 1 -- set HP to value
				end
				-- op12 (weapon damage)
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 0xC, -- Damage (12)
					["dwFlags"] = op12DamageType * 0x10000 + mode,
					["effectAmount"] = (selectedWeaponAbility.damageDiceCount == 0 and selectedWeaponAbility.damageDice == 0 and selectedWeaponAbility.damageDiceBonus == 0) and 0 or (selectedWeaponAbility.damageDiceBonus + modifier),
					["numDice"] = selectedWeaponAbility.damageDiceCount,
					["diceSize"] = selectedWeaponAbility.damageDice,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				-- apply on-hit effects (if any)
				for _, v in ipairs(onHitEffects) do
					local array = {}
					--
					if v["targetType"] == 1 or v["targetType"] == 9 then -- self / original caster
						table.insert(array, sourceSprite)
					elseif v["targetType"] == 2 then -- projectile target
						table.insert(array, CGameSprite)
					elseif v["targetType"] == 3 or (v["targetType"] == 6 and sourceSprite.m_typeAI.m_EnemyAlly == 2) then -- party
						for i = 0, 5 do
							local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
							if partyMember and EEex_BAnd(partyMember:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, partyMember)
							end
						end
					elseif v["targetType"] == 4 then -- everyone
						local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
						--
						for _, itrSprite in ipairs(everyone) do
							if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, itrSprite)
							end
						end
					elseif v["targetType"] == 5 then -- everyone but party
						local everyone = EEex_Area_GetAllOfTypeInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
						--
						for _, itrSprite in ipairs(everyone) do
							if itrSprite.m_typeAI.m_EnemyAlly ~= 2 then
								if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
									table.insert(array, itrSprite)
								end
							end
						end
					elseif v["targetType"] == 6 then -- caster group
						local casterGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", sourceSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
						--
						for _, itrSprite in ipairs(casterGroup) do
							if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, itrSprite)
							end
						end
					elseif v["targetType"] == 7 then -- target group
						local targetGroup = EEex_Area_GetAllOfTypeStringInRange(sourceSprite.m_pArea, sourceSprite.m_pos.x, sourceSprite.m_pos.y, string.format("[0.0.0.0.%d]", CGameSprite.m_typeAI.m_Specifics), 0x7FFF, false, nil, nil)
						--
						for _, itrSprite in ipairs(targetGroup) do
							if EEex_BAnd(itrSprite:getActiveStats().m_generalState, 0x800) == 0 then -- skip if STATE_DEAD
								table.insert(array, itrSprite)
							end
						end
					elseif v["targetType"] == 8 then -- everyone but self
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
							["effectID"] = v["effectID"],
							["spellLevel"] = v["spellLevel"],
							["effectAmount"] = v["effectAmount"],
							["dwFlags"] = v["dwFlags"],
							["durationType"] = v["durationType"],
							["m_flags"] = v["m_flags"],
							["duration"] = v["duration"],
							["probabilityUpper"] = v["probabilityUpper"],
							["probabilityLower"] = v["probabilityLower"],
							["res"] = v["res"],
							["numDice"] = v["numDice"],
							["diceSize"] = v["diceSize"],
							["savingThrow"] = v["savingThrow"],
							["saveMod"] = v["saveMod"],
							["special"] = v["special"],
							--
							["m_school"] = selectedWeaponAbility.school,
							["m_secondaryType"] = selectedWeaponAbility.secondaryType,
							--
							["m_sourceRes"] = selectedWeaponResRef,
							["m_sourceType"] = 2,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				end
			else
				-- display feedback message
				GT_Utility_DisplaySpriteMessage(sourceSprite,
					string.format("%s : %d + %d = %d : %s",
						Infinity_FetchString(%feedback_strref_smite_good%), roll, modifier, roll + modifier, Infinity_FetchString(%feedback_strref_miss%)),
					0x915D48, 0x915D48 -- Chrome Blue
				)
			end
		else
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display string
				["effectAmount"] = %feedback_strref_not_good%,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
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
	--
	weaponEffectiveVs:free()
	isGood:free()
end
