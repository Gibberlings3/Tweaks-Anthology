--[[
+----------------------------------+
| Check if the animal can level up |
+----------------------------------+
--]]

function GT_AnimalCompanion_CanLevelUp()
	local summonerID = EEex_LuaTrigger_Object.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	local summonerActiveStats = EEex_Sprite_GetActiveStats(summonerSprite)
	local summonerClass = summonerSprite.m_typeAI.m_Class
	local class = GT_Resource_SymbolToIDS["class"]
	--
	if summonerActiveStats.m_nLevelDrain == 0 then
		if summonerClass == class["CLERIC_RANGER"] then
			if summonerSprite.m_baseStats.m_level2 > EEex_LuaTrigger_Object.m_baseStats.m_level1 then
				return true
			else
				return false
			end
		else
			if summonerSprite.m_baseStats.m_level1 > EEex_LuaTrigger_Object.m_baseStats.m_level1 then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end
