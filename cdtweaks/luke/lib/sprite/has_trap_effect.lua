-- Returns true if the specified object can currently trap the given level --

function GT_Sprite_HasTrapEffect(sprite, level, sectype, flags)
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
		elseif effect.m_effectId == 0x103 and effect.m_dWFlags == level and sectype ~= 4 and EEex_IsBitUnset(flags, 0x2) then -- Spell trap (259) -> CANNOT trap effects of Secondary Type ``MagicAttack``; CANNOT trap EFF files with ``resist_dispel = BIT2``
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

