-- Returns true if the specified object can currently bounce the given level/projectile/school/sectype/resref --

function GT_Sprite_HasBounceEffects(sprite, level, projectileType, school, sectype, resref)
	local toReturn = false

	local func = function(effect)
		if effect.m_effectId == 0xC5 and effect.m_dWFlags == projectileType and sectype ~= 4 then -- Physical mirror (197) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCA and effect.m_dWFlags == school and sectype ~= 4 then -- Reflect spell school (202) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xE3 and effect.m_dWFlags == school and sectype ~= 4 then -- Spell school turning (227) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCB and effect.m_dWFlags == sectype and sectype ~= 4 then -- Reflect spell type (203) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xE4 and effect.m_dWFlags == sectype and sectype ~= 4 then -- Spell type turning (228) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC7 and effect.m_effectAmount == level and sectype ~= 4 then -- Reflect spell level (199) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC8 and effect.m_dWFlags == level and sectype ~= 4 then -- Spell turning (200) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCF and effect.m_res:get() == resref and sectype ~= 4 then -- Reflect specified spell (207) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		end
	end

	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, func)
	if not toReturn then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, func)
	end

	return toReturn
end

