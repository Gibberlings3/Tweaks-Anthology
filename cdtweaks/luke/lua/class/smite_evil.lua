--[[
+------------------------------------------------------+
| cdtweaks, NWN-ish Smite Evil class feat for Paladins |
+------------------------------------------------------+
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
		sprite:setLocalInt("gtNWNSmiteEvil", int)
		-- Get how many instances are currently memorized
		local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
		local memList = spellLevelMemListArray:getReference(0) -- *count starts from 0*
		local memorized = 0
		--
		EEex_Utility_IterateCPtrList(memList, function(memInstance)
			local memInstanceResref = memInstance.m_spellId:get()
			if memInstanceResref == "%PALADIN_SMITE_EVIL%" then
				local memFlags = memInstance.m_flags
				if EEex_IsBitSet(memFlags, 0x0) then
					memorized = memorized + 1
				end
			end
		end)
		--
		sprite:applyEffect({
			["effectID"] = 172, -- remove spell
			["res"] = "%PALADIN_SMITE_EVIL%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--
		for i = 1, int do
			sprite:applyEffect({
				["effectID"] = 171, -- give spell
				["res"] = "%PALADIN_SMITE_EVIL%",
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
				if memInstanceResref == "%PALADIN_SMITE_EVIL%" then
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
	local gainAbility = spriteClassStr == "PALADIN" and spriteKitStr ~= "Blackguard" and EEex_IsBitUnset(spriteFlags, 0x9)
	-- One use per level (starting from level 1)
	--local usesPerDay = math.floor(spriteLevel1 / 5) + 1
	local usesPerDay = math.floor(spriteLevel1 / 1) + 0
	--
	if sprite:getLocalInt("gtNWNSmiteEvil") == 0 then
		if gainAbility then
			gain(usesPerDay, false)
		end
	else
		if gainAbility then
			-- Check if level has changed since last application
			if usesPerDay ~= sprite:getLocalInt("gtNWNSmiteEvil") then
				gain(usesPerDay, true)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNSmiteEvil", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%PALADIN_SMITE_EVIL%",
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

	if not (curAction.m_actionID == 31 and resref == "%PALADIN_SMITE_EVIL%" and changeAmount < 0) then
		return
	end

	-- recast as ``ForceSpell()`` (so as to prevent spell disruption) --
	curAction.m_actionID = 113

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
	local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- *count starts from 0*

	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)

	-- restore memorization bit (in case of invalid weapon)
	if selectedWeapon["slot"] == 10 or selectedWeapon["slot"] == 34 or selectedWeapon["ability"].type ~= 1 then

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
		spriteAux["gt_NWN_SmiteEvil_TargetID"] = curAction.m_acteeID.m_Instance

		-- initialize the attack frame counter
		sprite.m_attackFrame = 0

	end

end)

-- Forget about ``spriteAux["gt_NWN_SmiteEvil_TargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtNWNSmiteEvil") > 0 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%PALADIN_SMITE_EVIL%") then
			if spriteAux["gt_NWN_SmiteEvil_TargetID"] ~= nil then
				spriteAux["gt_NWN_SmiteEvil_TargetID"] = nil
			end
		end
	end
end)

-- cast the actual spl (i.e. Smite Evil) when ``m_attackFrame`` is equal to 6 (that should be approx. the value corresponding to the weapon hit...?) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	--
	if sprite:getLocalInt("gtNWNSmiteEvil") > 0 then
		if not (selectedWeapon["slot"] == 10 or selectedWeapon["slot"] == 34 or selectedWeapon["ability"].type ~= 1) then
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gt_NWN_SmiteEvil_TargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gt_NWN_SmiteEvil_TargetID"])
					spriteAux["gt_NWN_SmiteEvil_TargetID"] = nil
					--
					if targetSprite then
						targetSprite:applyEffect({
							["effectID"] = 402, -- invoke lua
							["res"] = "%PALADIN_SMITE_EVIL%",
							["sourceID"] = sprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
						})
					end
				end
			end
		end
	end
end)

-- core op402 listener --

function %PALADIN_SMITE_EVIL%(CGameEffect, CGameSprite)
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
	local luck = sourceActiveStats.m_nLuck -- STAT 32
	local thac0BonusRight = sourceActiveStats.m_THAC0BonusRight -- this should include the bonus from the weapon + str + wspecial.2da + op284 (STAT 166) + stylbonu.2da + op288 (STAT 170)
	--local meleeTHAC0Bonus = sourceActiveStats.m_nMeleeTHAC0Bonus -- op284 (STAT 166)
	-- collect on-hit effects (if any)
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	--
	local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
	--
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
	-- op178
	local thac0VsTypeBonus = GT_Sprite_Thac0VsTypeBonus(sourceSprite, CGameSprite)
	-- op219
	local attackRollPenalty = GT_Sprite_AttackRollPenalty(sourceSprite, CGameSprite)
	-- racial enemy
	local racialEnemy = GT_Sprite_GetRacialEnemyBonus(sourceSprite, CGameSprite)
	-- attack of opportunity
	local attackOfOpportunity = GT_Sprite_GetAttackOfOpportunityBonus(sourceSprite, CGameSprite)
	-- invisibility
	local strikingFromInvisibility = GT_Sprite_StrikingFromInvisibilityBonus(sourceSprite, CGameSprite)
	local invisibleTarget = GT_Sprite_InvisibleTargetPenalty(sourceSprite, CGameSprite)
	-- op120
	local weaponEffectiveVs = 'WeaponEffectiveVs(EEex_Target("gtScriptingTarget"),MAINHAND)'
	-- alignment check
	local align = GT_Resource_SymbolToIDS["align"]
	local isEvil = GT_Sprite_CheckIDS(CGameSprite, align["MASK_EVIL"], 8)
	--
	if GT_EvalConditional["parseConditionalString"](sourceSprite, CGameSprite, weaponEffectiveVs) then
		if isEvil then
			-- compute attack roll (am I missing something...?)
			local success = false
			local modifier = luck + thac0BonusRight + thac0VsTypeBonus - attackRollPenalty + racialEnemy + attackOfOpportunity + strikingFromInvisibility - invisibleTarget + chrBonus
			--
			local criticalHitMod, criticalMissMod = GT_Sprite_GetCriticalModifiers(sourceSprite)
			--
			local m_nTimeStopCaster = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nTimeStopCaster
			--
			if (roll >= 20 - criticalHitMod) or EEex_BAnd(targetActiveStats.m_generalState, 0x100029) ~= 0 or m_nTimeStopCaster == sourceSprite.m_id then -- automatic hit
				success = true
				modifier = 0
			elseif roll <= 1 + criticalMissMod then -- automatic miss (critical failure)
				modifier = 0
			elseif roll + modifier >= thac0 - (targetActiveStats.m_nArmorClass + ACModifier) then
				success = true
			end
			--
			if success then
				-- display feedback message
				GT_Sprite_DisplayMessage(sourceSprite,
					string.format("%s : %d %s %d = %d : %s",
						Infinity_FetchString(%feedback_strref_smite_evil%), roll, modifier < 0 and "-" or "+", math.abs(modifier), roll + modifier, Infinity_FetchString(%feedback_strref_hit%)),
					0x3479BA -- Light Bronze
				)
				--
				local strmod = GT_Resource_2DA["strmod"]
				local strmodex = GT_Resource_2DA["strmodex"]
				--
				local strBonus = tonumber(strmod[string.format("%s", sourceActiveStats.m_nSTR)]["DAMAGE"])
				local strExtraBonus = sourceActiveStats.m_nSTR == 18 and tonumber(strmodex[string.format("%s", sourceActiveStats.m_nSTRExtra)]["DAMAGE"]) or 0
				local damageBonus = sourceActiveStats.m_nDamageBonus -- op73
				local damageBonusRight = sourceActiveStats.m_DamageBonusRight -- wspecial.2da + stylbonu.2da + op289 (STAT 171)
				local meleeDamageBonus = sourceActiveStats.m_nMeleeDamageBonus -- op285 (STAT 167)
				-- op179
				local damageVsTypeBonus = GT_Sprite_DamageVsTypeBonus(sourceSprite, CGameSprite)
				--
				local modifier = strBonus + strExtraBonus + damageBonus + damageBonusRight + meleeDamageBonus + damageVsTypeBonus + attackOfOpportunity + sourceActiveStats.m_nLevel1
				-- damage type ``NONE`` requires extra care
				local mode = 0 -- normal
				if selectedWeapon["ability"].damageType == 0 and selectedWeapon["ability"].damageDiceCount > 0 then
					mode = 1 -- set HP to value
				end
				-- op12 (weapon damage)
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 0xC, -- Damage (12)
					["dwFlags"] = damageTypeIDS * 0x10000 + mode,
					["effectAmount"] = (selectedWeapon["ability"].damageDiceCount == 0 and selectedWeapon["ability"].damageDice == 0 and selectedWeapon["ability"].damageDiceBonus == 0) and 0 or (selectedWeapon["ability"].damageDiceBonus + modifier),
					["numDice"] = selectedWeapon["ability"].damageDiceCount,
					["diceSize"] = selectedWeapon["ability"].damageDice,
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
				-- display feedback message
				GT_Sprite_DisplayMessage(sourceSprite,
					string.format("%s : %d %s %d = %d : %s",
						Infinity_FetchString(%feedback_strref_smite_evil%), roll, modifier < 0 and "-" or "+", math.abs(modifier), roll + modifier, Infinity_FetchString(%feedback_strref_miss%)),
					0x3479BA -- Light Bronze
				)
			end
		else
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display string
				["effectAmount"] = %feedback_strref_not_evil%,
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
end

