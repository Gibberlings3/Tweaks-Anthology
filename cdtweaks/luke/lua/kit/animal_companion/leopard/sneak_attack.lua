--[[
+--------------------------------------------------------------------------------------------------+
| Leopard: Can perform sneak attacks as if it was an assassin of the same level (see sneakatt.2da) |
+--------------------------------------------------------------------------------------------------+
--]]

function %INNATE_LEOPARD_SNEAK_ATTACK%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform a sneak attack
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		-- limit to once per round
		local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtLeopardSneakattTimer","LOCALS")')
		local responseString = EEex_Action_ParseResponseString('SetGlobalTimer("gtLeopardSneakattTimer","LOCALS",6)')
		--
		local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
		--
		if conditionalString:evalConditionalAsAIBase(sourceSprite) then
			-- if the target is incapacitated || the target is in combat with someone else || the target is equipped with a ranged weapon
			if EEex_BAnd(targetActiveStats.m_generalState, 0x100029) ~= 0 or CGameSprite.m_targetId ~= sourceSprite.m_id or isWeaponRanged:evalConditionalAsAIBase(CGameSprite) then
				responseString:executeResponseAsAIBaseInstantly(sourceSprite)
				--
				CGameSprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["res"] = "%INNATE_LEOPARD_SNEAK_ATTACK%", -- SPL file
					["dwFlags"] = 1, -- cast instantly / ignore level
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
		--
		isWeaponRanged:free()
		responseString:free()
		conditionalString:free()
	elseif CGameEffect.m_effectAmount == 2 then -- actual sneak attack
		local sneakatt = GT_Resource_2DA["sneakatt"]
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local op12DamageType, ACModifier = GT_Utility_DamageTypeConverter(selectedWeaponAbility.damageType, targetActiveStats)
		--
		if not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0xC, -- Damage
				["dwFlags"] = op12DamageType * 0x10000, -- mode: normal
				["numDice"] = tonumber(sneakatt["ASSASIN"][string.format("%s", sourceActiveStats.m_nLevel1)]), -- typo in KIT.IDS / KITLIST.2DA
				["diceSize"] = 6,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		else
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 324, -- Immunity to resource and message
				["res"] = CGameEffect.m_sourceRes:get(),
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
		--
		immunityToDamage:free()
	end
end
