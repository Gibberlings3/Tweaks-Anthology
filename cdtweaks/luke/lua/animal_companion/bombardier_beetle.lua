-- cdtweaks, Animal Companion (Bombardier Beetle Cloud): Stunning lasts for 2d4 rounds. Deafening lasts 2d6 rounds --

function GTACMP07(CGameEffect, CGameSprite)
	local stunDuration = math.random(4) + math.random(4) -- 2d4
	local deafDuration = math.random(6) + math.random(6) -- 2d6
	--
	local stunImmunity = false
	local deafImmunity = false
	local checkForImmunity = function(fx)
		if fx.m_effectId == 0x65 and fx.m_dWFlags == 45 then
			stunImmunity = true
		end
		if fx.m_effectId == 0x65 and fx.m_dWFlags == 80 then
			deafImmunity = true
		end
	end
	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, checkForImmunity)
	if not (stunImmunity and deafImmunity) then
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, checkForImmunity)
	end
	--
	if not stunImmunity then
		if math.random(5) == 1 then -- 20% chance
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 45, -- Stun
				["duration"] = 6 * stunDuration,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display String
				["durationType"] = 1,
				["effectAmount"] = %feedback_strref_stun%,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
	--
	if not deafImmunity then
		if math.random(5) == 1 then -- 20% chance
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 80, -- Deafness
				["duration"] = 6 * deafDuration,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 142, -- Icon
				["duration"] = 6 * deafDuration,
				["dwFlags"] = 112,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display String
				["durationType"] = 1,
				["effectAmount"] = %feedback_strref_deaf%,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
