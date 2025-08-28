-- Assume actions "MoveToPoint()" and "Attack()" are player-issued commands (as a result, do not interrupt them) --

function GT_LuaTrigger_InterruptableAction()
	if EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
		return true
	else
		return not (EEex_LuaTrigger_Object.m_curAction.m_actionID == 3 or EEex_LuaTrigger_Object.m_curAction.m_actionID == 23)
	end
end

