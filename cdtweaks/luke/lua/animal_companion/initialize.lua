-- cdtweaks, Animal Companion (Initialize): check if Animal Companion has already been summoned --

function GTACMP00(CGameEffect, CGameSprite)
	if EEex_Sprite_GetLocalInt(CGameSprite, "gtAnimalCompanion") == 1 then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 206, -- Protection from spell
			["effectAmount"] = %feedback_strref%, -- Animal Companion already summoned
			["res"] = CGameEffect.m_sourceRes:get(),
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
