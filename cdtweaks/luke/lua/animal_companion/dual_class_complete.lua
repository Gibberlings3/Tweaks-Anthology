-- cdtweaks, Animal Companion (all): check if the summoner is a complete dual-class character

function GT_AnimalCompanion_CheckIfIncompleteDualClass()
	local summonerID = EEex_LuaTrigger_Object.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	local summonerFlags = summonerSprite.m_baseStats.m_flags
	local summonerClass = summonerSprite.m_typeAI.m_Class
	local summonerLevel1 = summonerSprite.m_derivedStats.m_nLevel1
	local summonerLevel2 = summonerSprite.m_derivedStats.m_nLevel2
	--
	local class = GT_Resource_SymbolToIDS["class"]
	--
	if summonerClass == class["CLERIC_RANGER"] then
		if EEex_IsBitSet(summonerFlags, 0x8) then
			if summonerLevel1 > summonerLevel2 then
				return false
			else
				return true
			end
		else
			return false
		end
	else
		return false
	end
end
