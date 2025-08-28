-- check if PartyAI is ON/OFF --

function GT_LuaTrigger_PartyAI()
	if EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
		return true
	else
		return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_bPartyAI == 1
	end
end

