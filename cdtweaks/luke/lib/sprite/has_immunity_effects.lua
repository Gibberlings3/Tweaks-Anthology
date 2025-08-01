-- Returns true if the specified object can currently deflect the given level/projectile/school/sectype/resref/opcode(s) --

function GT_Sprite_HasImmunityEffects(sprite, level, projectileType, school, sectype, resref, opcodes, flags, savetype, immunitiesVia403)
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
		elseif effect.m_effectId == 0x53 and effect.m_dWFlags == projectileType then -- Immunity to projectile (83) -> CAN block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0x65 and GT_Utility_ArrayContains(opcodes, effect.m_dWFlags) and EEex_IsBitUnset(savetype, 23) then -- Immunity to opcode (101)
			toReturn = true
			return true
		elseif effect.m_effectId == 0x66 and effect.m_effectAmount == level then -- Immunity to spell level (102) -> CAN block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xC9 and effect.m_dWFlags == level and sectype ~= 4 and EEex_IsBitUnset(flags, 0x2) then -- Spell deflection (201) -> CANNOT block effects of Secondary Type ``MagicAttack``; CANNOT block EFF files with ``resist_dispel = BIT2``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCC and effect.m_dWFlags == school and sectype ~= 4 then -- Protection from spell school (204) -> CANNOT block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCD and effect.m_dWFlags == sectype and sectype ~= 4 then -- Protection from spell type (205) -> CANNOT block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xCE and effect.m_res:get() == resref then -- Protection from spell (206) -> CAN block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xDF and effect.m_dWFlags == school and sectype ~= 4 then -- Spell school deflection (223) -> CANNOT block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0xE2 and effect.m_dWFlags == sectype then -- Spell type deflection (226) -> CAN block effects of Secondary Type ``MagicAttack``
			toReturn = true
			return true
		elseif effect.m_effectId == 0x193 and effect.m_res:get() == "GTIMMUNE" and EEex_BAnd(effect.m_dWFlags, immunitiesVia403) ~= 0 then -- EEex Screen Effects (403) -> See the special cases in "misc\immunity_removal.lua"
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

