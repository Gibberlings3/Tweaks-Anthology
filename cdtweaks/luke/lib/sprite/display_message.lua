-- Display a colored string in the combat log --

function GT_Sprite_DisplayMessage(sprite, messageStr, messageColor)

	local message = EEex_NewUD("CMessageDisplayText")

	EEex_RunWithStackManager({
		{ ["name"] = "messageStr", ["struct"] = "CString", ["constructor"] = {["args"] = {messageStr} } } },
		function(manager)
			local id = sprite.m_id
			message:Construct(
				sprite:GetName(true),
				manager:getUD("messageStr"),
				CVidPalette.RANGE_COLORS:get(sprite.m_baseStats.m_colors:get(2)),
				messageColor == nil and 0xBED7D7 or messageColor,
				-1, id, id
			)
		end
	)

	EngineGlobals.g_pBaldurChitin.m_cMessageHandler:AddMessage(message, false)

end

