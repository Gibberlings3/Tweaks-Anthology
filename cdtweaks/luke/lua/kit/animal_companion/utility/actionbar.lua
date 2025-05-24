--[[
+-----------------------------------------------------------------------------------------+
| Leopard: set the RANGER action bar (so as to have access to the Hide in Shadows button) |
+-----------------------------------------------------------------------------------------+
--]]

EEex_Actionbar_AddListener(function(config, state)

	local sprite = EEex_Sprite_GetSelected() -- will always return the sprite that the actionbar currently reflects
	if not sprite then
		return
	end

	if sprite.m_scriptName:get() == "gtAnmlCompLeopard" then
		if state == 112 then -- Controlled (Class doesn't have a dedicated state)
			EEex_Actionbar_SetState(12) -- Ranger
		end
	end
end)
