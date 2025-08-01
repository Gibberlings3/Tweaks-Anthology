-- Returns true if the specified object can currently bounce the given level/projectile/school/sectype/resref/opcode(s) --

function GT_Sprite_HasBounceEffects(sprite, level, projectileType, school, sectype, resref, opcodes, flags)
	local toReturn = false

	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				if func(CGameEffectBase) then
					toReturn = true
					return true
				end
			end
		elseif effect.m_effectId == 0xC5 and effect.m_dWFlags == projectileType and sectype ~= 4 then -- Physical mirror (197) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC6 and GT_Utility_ArrayContains(opcodes, effect.m_dWFlags) and sectype ~= 4 then -- Reflect specified effect (198) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC7 and effect.m_effectAmount == level and sectype ~= 4 and EEex_IsBitUnset(flags, 0x2) then -- Reflect spell level (199) -> CANNOT bounce effects of Secondary Type ``MagicAttack``; CANNOT bounce EFF files with ``resist_dispel = BIT2``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC8 and effect.m_dWFlags == level and sectype ~= 4 and EEex_IsBitUnset(flags, 0x2) then -- Spell turning (200) -> CANNOT bounce effects of Secondary Type ``MagicAttack``; CANNOT bounce EFF files with ``resist_dispel = BIT2``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCA and effect.m_dWFlags == school and sectype ~= 4 then -- Reflect spell school (202) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCB and effect.m_dWFlags == sectype and sectype ~= 4 then -- Reflect spell type (203) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCF and effect.m_res:get() == resref and sectype ~= 4 then -- Reflect specified spell (207) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xE3 and effect.m_dWFlags == school and sectype ~= 4 then -- Spell school turning (227) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xE4 and effect.m_dWFlags == sectype and sectype ~= 4 then -- Spell type turning (228) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
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

