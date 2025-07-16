--[[
+----------------------------------------------------------------------------------------------------------------------------------------------------+
| Check if the Animal Companion has already been summoned; restore var "gtAnimalCompanion" on the summoner when the animal gets slained / unsummoned |
+----------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

function %BEASTMASTER_ANIMAL_COMPANION%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 0 then
		if EEex_Sprite_GetLocalInt(CGameSprite, "gtNWNAnimalCompanion") == 1 then
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
	elseif CGameEffect.m_effectAmount == 1 then
		local summonerID = CGameSprite.m_lSummonedBy.m_Instance
		local summonerSprite = EEex_GameObject_Get(summonerID)
		--
		EEex_Sprite_SetLocalInt(summonerSprite, "gtNWNAnimalCompanion", 0)
	end
end