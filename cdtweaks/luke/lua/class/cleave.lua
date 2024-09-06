-- cdtweaks: NWN-ish Cleave feat for Fighters --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksCleave", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "%FIGHTER_CLEAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["durationType"] = 9,
			["res"] = "%FIGHTER_CLEAVE%B", -- EFF file
			["m_sourceRes"] = "%FIGHTER_CLEAVE%",
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
	-- any fighter class (single/multi/(complete)dual)
	local applyAbility = spriteClassStr == "FIGHTER" or spriteClassStr == "FIGHTER_MAGE_THIEF" or spriteClassStr == "FIGHTER_MAGE_CLERIC"
		or (spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
	--
	if sprite:getLocalInt("cdtweaksCleave") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksCleave", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "%FIGHTER_CLEAVE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks, NWN-ish Cleave feat for Fighters --

function %FIGHTER_CLEAVE%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform Cleave
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local sourceSeeInvisible = sourceSprite.m_derivedStats.m_bSeeInvisible + sourceSprite.m_bonusStats.m_bSeeInvisible
		--
		local inWeaponRange = EEex_Trigger_ParseConditionalString('InWeaponRange(EEex_Target("GT_FighterCleaveTarget"))')
		local reallyForceSpell = EEex_Action_ParseResponseString('ReallyForceSpellRES("%FIGHTER_CLEAVE%B",EEex_Target("GT_FighterCleaveTarget"))')
		--
		local targetGeneralState = CGameSprite.m_derivedStats.m_generalState + CGameSprite.m_bonusStats.m_generalState
		--
		if EEex_IsBitSet(targetGeneralState, 11) then -- if STATE_DEAD (BIT11)
			local spriteArray = {}
			if sourceSprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sourceSprite, "[GOODCUTOFF]", sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
			elseif sourceSprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sourceSprite, "[EVILCUTOFF]", sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
			end
			--
			for _, itrSprite in ipairs(spriteArray) do
				sourceSprite:setStoredScriptingTarget("GT_FighterCleaveTarget", itrSprite)
				--
				local itrSpriteGeneralState = itrSprite.m_derivedStats.m_generalState + itrSprite.m_bonusStats.m_generalState
				local itrSpriteSanctuary = itrSprite.m_derivedStats.m_bSanctuary + itrSprite.m_bonusStats.m_bSanctuary
				--
				if inWeaponRange:evalConditionalAsAIBase(sourceSprite) and EEex_IsBitUnset(spriteGeneralState, 11) then -- if not dead
					if EEex_IsBitUnset(itrSpriteGeneralState, 0x4) or sourceSeeInvisible > 0 then
						if itrSpriteSanctuary == 0 then
							reallyForceSpell:executeResponseAsAIBaseInstantly(sourceSprite)
							break
						end
					end
				end
			end
		end
		--
		inWeaponRange:free()
		reallyForceSpell:free()
	elseif CGameEffect.m_effectAmount == 2 then -- actual feat
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		local randomValue = math.random(0, 1)
		local damageType = {16, 0, 256, 128, 2048, 16 * randomValue, randomValue == 0 and 16 or 256, 256 * randomValue} -- piercing, crushing, slashing, missile, non-lethal, piercing/crushing, piercing/slashing, slashing/crushing
		if damageType[selectedWeaponAbility.damageType] then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 12, -- Damage
				["dwFlags"] = damageType[selectedWeaponAbility.damageType] * 0x10000, -- Normal
				["durationType"] = 1,
				["numDice"] = selectedWeaponAbility.damageDiceCount,
				["diceSize"] = selectedWeaponAbility.damageDice,
				["effectAmount"] = selectedWeaponAbility.damageDiceBonus,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
