--[[
+------------------------------------------------------------------------+
| cdtweaks, NWN-ish Dirty Fighting class feat for chaotic-aligned rogues |
+------------------------------------------------------------------------+
--]]

-- Apply Ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtThiefDirtyFighting", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%THIEF_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["durationType"] = 9,
			["res"] = "%THIEF_DIRTY_FIGHTING%B", -- EFF file
			["m_sourceRes"] = "%THIEF_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- Check if rogue class -- single/multi/(complete)dual
	local applyAbility = spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	-- Check if chaotic
	local alignmentMaskChaotic = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_CHAOTIC)")
	--
	local applyAbility = applyAbility and alignmentMaskChaotic:evalConditionalAsAIBase(sprite)
	--
	if sprite:getLocalInt("gtThiefDirtyFighting") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtThiefDirtyFighting", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%THIEF_DIRTY_FIGHTING%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	alignmentMaskChaotic:free()
end)

-- Core op402 listener --

function %THIEF_DIRTY_FIGHTING%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	local sourceAux = EEex_GetUDAux(sourceSprite)
	--
	local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local isUsableBySingleClassThief = EEex_IsBitUnset(selectedWeaponHeader.notUsableBy, 22)
	--
	if sourceSprite.m_leftAttack == 1 then -- if off-hand attack
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		local offHand = items:get(9) -- CItem
		--
		if offHand then -- sanity check
			local pHeader = offHand.pRes.pHeader -- Item_Header_st
			if not (pHeader.itemType == 0xC) then -- if not shield, then overwrite item ability/usability check...
				selectedWeaponAbility = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
				isUsableBySingleClassThief = EEex_IsBitUnset(pHeader.notUsableBy, 22)
			end
		end
	end
	--
	local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local resistDamageTypeTable = {
		[0x10] = targetActiveStats.m_nResistPiercing, -- piercing
		[0x0] = targetActiveStats.m_nResistCrushing, -- crushing
		[0x100] = targetActiveStats.m_nResistSlashing, -- slashing
		[0x80] = targetActiveStats.m_nResistMissile, -- missile
		[0x800] = targetActiveStats.m_nResistCrushing, -- non-lethal
	}
	--
	local op12DamageType, ACModifier = GT_Utility_DamageTypeConverter(selectedWeaponAbility.damageType, targetActiveStats)
	--
	if sourceAux["gt_ThiefDirtyFighting_FirstAttack"] then
		if isUsableBySingleClassThief then
			if resistDamageTypeTable[op12DamageType] < 100 and not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
				-- 5% unmitigated damage
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 0xC, -- Damage
					["dwFlags"] = op12DamageType * 0x10000 + 3, -- mode: reduce by percentage
					--["numDice"] = 1,
					--["diceSize"] = 4,
					["effectAmount"] = 5,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				-- the percentage mode of op12 does not provide feedback, so we have to manually display it...
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Display string
					["effectAmount"] = %feedback_strref_hit%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			else
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Immunity to resource and message
					["effectAmount"] = %feedback_strref_immune%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
	--
	immunityToDamage:free()
end

-- Flag first attack in each round --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtDirtyFightingTimer" then -- dummy opcode that acts as a marker/timer
			found = true
			return true
		end
	end)
	--local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtDirtyFightingTimer","LOCALS")')
	--local responseString = EEex_Action_ParseResponseString('SetGlobalTimer("gtDirtyFightingTimer","LOCALS",6)')
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtThiefDirtyFighting") == 1 then
		if sprite.m_startedSwing == 1 then
			if not found then
				-- set timer
				sprite:applyEffect({
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_DUMMY_STAT"],
					["noSave"] = true,
					["m_scriptName"] = "gtDirtyFightingTimer",
					["duration"] = 90,
					["durationType"] = 10, -- instant/limited (ticks)
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				--
				spriteAux["gt_ThiefDirtyFighting_FirstAttack"] = true
			end
		else
			if found and spriteAux["gt_ThiefDirtyFighting_FirstAttack"] then
				spriteAux["gt_ThiefDirtyFighting_FirstAttack"] = false
			end
		end
	end
	--
	--conditionalString:free()
	--responseString:free()
end)

