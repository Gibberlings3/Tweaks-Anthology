-- check if spellcasting is disabled via op145 --

function GT_Sprite_SpellcastingDisabled(CGameSprite, spellType)
	local toReturn = false
	--
	local func = function(effect)
		if effect.m_effectId == 145 then
			if effect.m_dWFlags == 0 and spellType == 1 then -- wizard
				toReturn = true
				return true
			elseif effect.m_dWFlags == 1 and spellType == 2 then -- priest
				toReturn = true
				return true
			elseif effect.m_dWFlags == 3 then -- both
				toReturn = true
				return true
			end
		end
	end
	--
	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, func)
	if not toReturn then
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, func)
	end
	--
	return toReturn
end

