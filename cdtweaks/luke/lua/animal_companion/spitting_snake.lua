-- cdtweaks, Animal Companion (Spitting Snake): Blindness lasts 2d6 rounds --

function GTACMP07(CGameEffect, CGameSprite)
	local blindDuration = math.random(6) + math.random(6) -- 2d6
	--
	local blindImmunity = false
	local checkForImmunity = function(fx)
		if fx.m_effectId == 0x65 and fx.m_dWFlags == 74 then
			blindImmunity = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, checkForImmunity)
	if not blindImmunity then
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, checkForImmunity)
	end
	--
	if not blindImmunity then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 74, -- Blindness
			["duration"] = 6 * blindDuration,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 139, -- Display String
			["durationType"] = 1,
			["effectAmount"] = %feedback_strref_blind%,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
