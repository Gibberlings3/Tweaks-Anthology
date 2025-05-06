--[[
+----------------------+
| Blade Ward (cantrip) |
+----------------------+
--]]

-- Take only half the damage from base weapon attacks --

EEex_Sprite_AddAlterBaseWeaponDamageListener(function(context)
	local effect = context.effect -- CGameEffect
	local target = context.target -- CGameSprite
	--
	local damageAmount = effect.m_effectAmount
	--
	local isCritical = context.isCritical
	--
	local pHeader = EEex_Resource_Demand(context.weapon.cResRef:get(), "itm")
	--
	local found = false
	EEex_Utility_IterateCPtrList(target.m_timedEffectList, function(timedEffect)
		if timedEffect.m_effectId == 142 and timedEffect.m_dWFlags == %feedback_icon% then
			found = true
			return true
		end
	end)
	--
	if found then
		if not isCritical then -- skip critical hits
			if EEex_IsBitUnset(pHeader.itemFlags, 0x6) then -- skip magical weapons
				if effect.m_effectId == 0xC and effect.m_slotNum == -1 and effect.m_sourceType == 0 and effect.m_sourceRes:get() == "" then -- base weapon damage
					effect.m_effectAmount = math.floor(damageAmount / 2)
				end
			end
		end
	end
end)

