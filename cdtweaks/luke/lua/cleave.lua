-- cdtweaks, NWN-ish Cleave feat for Fighters --

function GTCLV01(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	local sourceSeeInvisible = sourceSprite.m_derivedStats.m_bSeeInvisible + sourceSprite.m_bonusStats.m_bSeeInvisible
	--
	local inWeaponRange = EEex_Trigger_ParseConditionalString("InWeaponRange(EEex_LuaObject)")
	local reallyForceSpell = EEex_Action_ParseResponseString('ReallyForceSpellRES("CDCLEAVE",EEex_LuaObject)')
	--
	local targetGeneralState = CGameSprite.m_derivedStats.m_generalState + CGameSprite.m_bonusStats.m_generalState
	--
	if EEex_IsBitSet(targetGeneralState, 11) then -- STATE_DEAD (BIT11)
		local spriteArray = {}
		if sourceSprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sourceSprite, "[GOODCUTOFF]", sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		elseif sourceSprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(sourceSprite, "[EVILCUTOFF]", sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		end
		--
		for _, itrSprite in ipairs(spriteArray) do
			EEex_LuaObject = itrSprite -- must be global
			local spriteGeneralState = itrSprite.m_derivedStats.m_generalState + itrSprite.m_bonusStats.m_generalState
			--
			if inWeaponRange:evalConditionalAsAIBase(sourceSprite) and EEex_IsBitUnset(spriteGeneralState, 11) then
				if EEex_IsBitUnset(spriteGeneralState, 0x4) or sourceSeeInvisible > 0 then
					reallyForceSpell:executeResponseAsAIBaseInstantly(sourceSprite)
					break
				end
			end
		end
	end
	--
	inWeaponRange:free()
	reallyForceSpell:free()
end

-- cdtweaks, NWN-ish Cleave feat for Fighters --

function GTCLV02(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	local equipment = sourceSprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	--
	local itemAbility = EEex_Resource_GetItemAbility(itemHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local randomValue = math.random(0, 1)
	local damageType = {16, 0, 256, 128, 2048, 16 * randomValue, randomValue == 0 and 16 or 256, 256 * randomValue} -- piercing, crushing, slashing, missile, non-lethal, piercing/crushing, piercing/slashing, slashing/crushing
	if damageType[itemAbility.damageType] then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 12, -- Damage
			["dwFlags"] = damageType[itemAbility.damageType] * 0x10000, -- Normal
			["durationType"] = 1,
			["numDice"] = itemAbility.damageDiceCount,
			["diceSize"] = itemAbility.damageDice,
			["effectAmount"] = itemAbility.damageDiceBonus,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
