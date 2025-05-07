-- Utility: Display a colored string in the combat log --

function GT_Utility_DisplaySpriteMessage(sprite, messageStr, spriteColor, messageColor)

	local message = EEex_NewUD("CMessageDisplayText")

	EEex_RunWithStackManager({
		{ ["name"] = "messageStr", ["struct"] = "CString", ["constructor"] = {["args"] = {messageStr} } } },
		function(manager)
			local id = sprite.m_id
			message:Construct(sprite:GetName(true), manager:getUD("messageStr"), spriteColor, messageColor, -1, id, id)
		end
	)

	EngineGlobals.g_pBaldurChitin.m_cMessageHandler:AddMessage(message, false)

end
