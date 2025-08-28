-- check if the active creature is in chase mode --

function GT_LuaTrigger_IsChasing()
	local str = 'InWeaponRange(EEex_Target("gtChasingTarget"))'
	local target = EEex_GameObject_Get(EEex_LuaTrigger_Object.m_targetId)
	local m_actionID = EEex_LuaTrigger_Object.m_curAction.m_actionID
	--
	return m_actionID == 134 and EEex_LuaTrigger_Object.m_followCount == 0 and target and GT_EvalConditional["parseConditionalString"](EEex_LuaTrigger_Object, target, str, "gtChasingTarget")
end

