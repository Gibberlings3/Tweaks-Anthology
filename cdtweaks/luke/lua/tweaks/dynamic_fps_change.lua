--[[
+-------------------------------------------------------+
| cdtweaks: automatically change FPS during playthrough |
+-------------------------------------------------------+
--]]

-- When in cutscene, lock FPS to 30 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	if sprite.m_inCutScene == 1 then
		if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
			EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
		end
	end
end)

-- When in combat, lock FPS to 30. Otherwise, set to 60 --

function GT_LuaAction_DynamicFPSChange()
	-- [Bubb] Each area has its own combat counter. You can check the global script runner's area in this way...
	local globalScriptRunnerId = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nAIIndex
	local globalScriptRunner = EEex_GameObject_Get(globalScriptRunnerId) -- CGameSprite
	local globalScriptRunnerArea = globalScriptRunner.m_pArea -- CGameArea
	--local globalScriptRunnerAreaResref = globalScriptRunnerArea and globalScriptRunnerArea.m_resref:get() or "nil"
	--Infinity_DisplayString(string.format("Global script runner area resref: \"%s\"", globalScriptRunnerAreaResref))
	--
	if globalScriptRunnerArea then
		if globalScriptRunnerArea.m_nBattleSongCounter > 0 then
			if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 30 then
				EEex_CChitin.TIMER_UPDATES_PER_SECOND = 30
			end
		else
			if EEex_CChitin.TIMER_UPDATES_PER_SECOND ~= 60 then
				EEex_CChitin.TIMER_UPDATES_PER_SECOND = 60
			end
		end
	end
end
