--[[
+--------------------------------------------------------------------------+
| Check if the summoner is a complete dual-class character / fallen ranger |
+--------------------------------------------------------------------------+
--]]

function GT_AnimalCompanion_SummonerClassCheck()
	local summonerID = EEex_LuaTrigger_Object.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	local summonerFlags = summonerSprite.m_baseStats.m_flags
	local summonerClass = summonerSprite.m_typeAI.m_Class
	local summonerLevel1 = summonerSprite:getActiveStats().m_nLevel1
	local summonerLevel2 = summonerSprite:getActiveStats().m_nLevel2
	--
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local toReturn
	--
	if EEex_IsBitUnset(summonerFlags, 10) then -- not fallen ranger
		if summonerClass == class["CLERIC_RANGER"] then
			if EEex_IsBitSet(summonerFlags, 0x8) then -- original class is ranger
				if summonerLevel1 > summonerLevel2 then
					toReturn = true
				else
					toReturn = false
				end
			else
				toReturn = true -- multiclass
			end
		else
			toReturn = true -- single class
		end
	else
		toReturn = false -- fallen ranger
	end
	--
	return not toReturn
end
