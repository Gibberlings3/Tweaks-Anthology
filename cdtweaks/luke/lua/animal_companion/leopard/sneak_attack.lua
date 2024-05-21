-- cdtweaks, Animal Companion (Leopard): Deal extra piercing damage when striking from invisibility --

function GTACP04B(CGameEffect, CGameSprite)
	local sneakatt = GT_Resource_2DA["sneakatt"]
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	local sourceLevel = sourceSprite.m_derivedStats.m_nLevel1 + sourceSprite.m_bonusStats.m_nLevel1
	--
	if tonumber(sneakatt["THIEF"][string.format("%s", sourceLevel)]) > 0 then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 12, -- Damage
			["dwFlags"] = 16 * 0x10000, -- Normal, Piercing
			["numDice"] = tonumber(sneakatt["THIEF"][string.format("%s", sourceLevel)]),
			["diceSize"] = 6,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
