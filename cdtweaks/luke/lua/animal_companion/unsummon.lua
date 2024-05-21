-- cdtweaks, Animal Companion (Unsummon Creature): restore var "gtAnimalCompanion" on the summoner --

function GTACP_00(CGameEffect, CGameSprite)
	local summonerID = CGameSprite.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	EEex_Sprite_SetLocalInt(summonerSprite, "gtAnimalCompanion", 0)
end
