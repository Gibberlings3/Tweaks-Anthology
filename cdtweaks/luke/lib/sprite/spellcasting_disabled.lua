-- check if spellcasting is disabled via op145 --

function GT_Sprite_SpellcastingDisabled(CGameSprite, spellType)
	local toReturn = false
	--
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
		elseif effect.m_effectId == 145 then
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

