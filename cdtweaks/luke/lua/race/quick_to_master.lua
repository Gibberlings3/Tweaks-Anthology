--[[
+----------------------------------------------------------+
| cdtweaks, NWN-ish Quick to Master racial feat for Humans |
+----------------------------------------------------------+
--]]

-- Humans start with an extra proficiency point at character generation --

EEex_GameState_AddInitializedListener(function()
	local old = CScreenCreateChar.OnMenuButtonClick
	--
	CScreenCreateChar.OnMenuButtonClick = function(self)
		old(self)
		--
		local engineCreateChar = EngineGlobals.g_pBaldurChitin.m_pEngineCreateChar -- CScreenCreateChar
		local sprite = EEex_GameObject_Get(engineCreateChar.m_nGameSprite) -- CGameSprite
		--
		if sprite and GT_EvalConditional["parseConditionalString"](sprite, nil, "Race(Myself,HUMAN)") and engineCreateChar.m_nCurrentStep == CScreenCreateCharStep.CSCREENCREATECHAR_STEP_PROFICIENCIES then
			engineCreateChar.m_nExtraProficiencySlots = engineCreateChar.m_nExtraProficiencySlots + 1 -- actual value
			chargen.extraProficiencySlots = chargen.extraProficiencySlots + 1 -- UI display value (cosmetic only)
		end
	end
end)

