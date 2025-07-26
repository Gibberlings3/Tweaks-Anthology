--[[
+---------------------------------------------------------------------+
| cdtweaks, alternate concentration check (fix bugged "CONCENTR.2DA") |
+---------------------------------------------------------------------+
--]]

function gtAlterConcentrationCheck(sprite, damageData)

	local curAction = sprite.m_curAction

	-- Get the spell that is currently being cast
	local spellResRef = curAction.m_string1.m_pchData:get()
	if spellResRef == "" then
		spellResRef = GT_Utility_DecodeSpell(curAction.m_specificID)
	end
	local spellLevel = EEex_Resource_Demand(spellResRef, "SPL").spellLevel

	-- Fetch components of check
	local roll = math.random(20) - 1
	local luck = sprite:getActiveStats().m_nLuck
	local con = sprite:getActiveStats().m_nCON
	local conBonus = math.floor(con / 2) - 5
	local damageTaken = damageData.damageTaken

	-- Do check
	local casterRoll = roll + %value1%
	local attackerRoll = spellLevel + %value2%
	local disrupted = casterRoll <= attackerRoll

	-- Feedback
	if not disrupted then
		GT_Sprite_DisplayMessage(sprite,
			string.format("%s : %d > %d : [%d (1d20 - 1) + %d (%s)] > [%d (%s) + %d (%s)]",
				Infinity_FetchString(%feedback_strref_concentr_check%), casterRoll, attackerRoll, roll, %value1%, Infinity_FetchString(%feedback_strref_value1%), spellLevel, Infinity_FetchString(%feedback_strref_spell_level%), %value2%, Infinity_FetchString(%feedback_strref_value2%)),
			0x8D6140 -- Dark Muddish Brown
		)
	end

	-- Return interruption result
	return disrupted
end
