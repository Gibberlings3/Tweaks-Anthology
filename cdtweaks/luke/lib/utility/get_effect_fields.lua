-- Get ``CGameEffect`` fields --

function GT_Utility_GetEffectFields(CGameEffect)
	local toReturn = {}
	--
	toReturn["parameter1"] = CGameEffect.m_effectAmount
	toReturn["parameter2"] = CGameEffect.m_dWFlags
	toReturn["numDice"] = CGameEffect.m_numDice
	toReturn["diceSize"] = CGameEffect.m_diceSize
	--
	toReturn["effectID"] = CGameEffect.m_effectId
	toReturn["spellLevel"] = CGameEffect.m_spellLevel
	toReturn["projectileType"] = CGameEffect.m_projectileType
	toReturn["school"] = CGameEffect.m_school
	toReturn["secondaryType"] = CGameEffect.m_secondaryType
	toReturn["sourceRes"] = CGameEffect.m_sourceRes:get()
	--
	toReturn["casterLevel"] = CGameEffect.m_casterLevel
	toReturn["flags"] = CGameEffect.m_flags
	toReturn["savingThrow"] = CGameEffect.m_savingThrow
	toReturn["saveMod"] = CGameEffect.m_saveMod
	toReturn["special"] = CGameEffect.m_special
	--
	toReturn["sourceType"] = CGameEffect.m_sourceType
	toReturn["sourceFlags"] = CGameEffect.m_sourceFlags
	toReturn["slotNum"] = CGameEffect.m_slotNum
	toReturn["scriptName"] = CGameEffect.m_scriptName:get()
	--
	toReturn["duration"] = CGameEffect.m_duration
	toReturn["timing"] = CGameEffect.m_durationType
	toReturn["timeApplied"] = CGameEffect.m_effectAmount5
	--
	return toReturn
end

