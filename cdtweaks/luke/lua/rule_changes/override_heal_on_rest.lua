--[[
+-----------------------------------------------+
| cdtweaks, override game option 'HEAL_ON_REST' |
+-----------------------------------------------+
--]]

EEex_GameState_AddInitializedListener(function()
	-- get option_id
	local option_id
	local panel_id = 8
	for _, v in ipairs(toggleTitles) do
		if v[1] == "HEAL_ON_REST_LABEL" then
			option_id = v[3]
			break
		end
	end
	if not option_id then
		EEex_Error("option_id for HEAL_ON_REST_LABEL not found!")
	end
	-- CBaldurEngine
	local old = CBaldurEngine.OnRestButtonClick
	CBaldurEngine.OnRestButtonClick = function(...)
		Infinity_ChangeOption(option_id, 0, panel_id)
		old(...)
	end
	-- CScreenStore
	local old = CScreenStore.OnRentRoomButtonClick
	CScreenStore.OnRentRoomButtonClick = function(...)
		Infinity_ChangeOption(option_id, 0, panel_id)
		old(...)
	end
end)
