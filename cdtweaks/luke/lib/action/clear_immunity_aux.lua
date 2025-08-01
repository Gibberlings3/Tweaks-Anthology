-- clear immunity aux if there is no ongoing combat (you know, we are not confortable with tables that grow indefinitely...) --

function GT_LuaAction_ClearImmunityAux()
	-- [Bubb] Each area has its own combat counter. You can check the global script runner's area in this way...
	local globalScriptRunnerId = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nAIIndex
	local globalScriptRunner = EEex_GameObject_Get(globalScriptRunnerId) -- CGameSprite
	local globalScriptRunnerArea = globalScriptRunner.m_pArea -- CGameArea
	--
	if globalScriptRunnerArea and globalScriptRunnerArea.m_nBattleSongCounter <= 0 then
		local everyone = EEex_Area_GetAllOfTypeInRange(globalScriptRunnerArea, globalScriptRunner.m_pos.x, globalScriptRunner.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
		--
		for _, itrSprite in ipairs(everyone) do
			local aux = EEex_GetUDAux(itrSprite)
			--
			if aux["gtImmunitiesVia403"] then
				aux["gtImmunitiesVia403"] = nil
			end
		end
	end
end

