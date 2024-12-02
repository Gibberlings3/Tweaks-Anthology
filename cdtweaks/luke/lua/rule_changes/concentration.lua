--[[
+---------------------------------------------------------------------+
| cdtweaks, alternate concentration check (fix bugged "CONCENTR.2DA") |
+---------------------------------------------------------------------+
--]]

local function cdtweaks_AlterConcentrationCheck_DisplaySpriteMessage(sprite, messageStr)

	local message = EEex_NewUD("CMessageDisplayText")

	EEex_RunWithStackManager({
		{ ["name"] = "messageStr", ["struct"] = "CString", ["constructor"] = {["args"] = {messageStr} } } },
		function(manager)
			local id = sprite.m_id
			message:Construct(sprite:GetName(true), manager:getUD("messageStr"), 0xBED7D7, 0xBED7D7, -1, id, id)
		end
	)

	EngineGlobals.g_pBaldurChitin.m_cMessageHandler:AddMessage(message, false);
end

function cdtweaks_AlterConcentrationCheck(sprite, damageData)

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
		cdtweaks_AlterConcentrationCheck_DisplaySpriteMessage(sprite,
			string.format("%s : %d > %d : [%d (1d20 - 1) + %d (%s)] > [%d (%s) + %d (%s)]",
			Infinity_FetchString(%feedback_strref_concentr_check%), casterRoll, attackerRoll, roll, %value1%, Infinity_FetchString(%feedback_strref_value1%), spellLevel, Infinity_FetchString(%feedback_strref_spell_level%), %value2%, Infinity_FetchString(%feedback_strref_value2%))
		)
	end

	-- Return interruption result
	return disrupted
end
