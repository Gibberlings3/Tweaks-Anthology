--[[
+------------------------------------------------------------------------------+
| cdtweaks, Limit resting mechanic (at most once every 24 in-game hours)       |
+------------------------------------------------------------------------------+
| scripted resting will not be blocked; however, it will still reset the timer |
+------------------------------------------------------------------------------+
--]]

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite.m_typeAI.m_EnemyAlly == 2 and action.m_actionID == 96 then -- if [PC] and "Rest()"
		sprite:applyEffect({
			["effectID"] = 0x141, -- Remove effects by resource (321)
			["res"] = "GTRULE01",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--
		sprite:applyEffect({
			["effectID"] = 0x152, -- Disable rest or save (338)
			["effectAmount"] = %feedback_strref%,
			["duration"] = 7200,
			["m_sourceRes"] = "GTRULE01",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
end)
