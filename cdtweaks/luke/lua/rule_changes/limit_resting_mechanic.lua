--[[
+------------------------------------------------------------------------------+
| cdtweaks, Limit resting mechanic (at most once every 24 in-game hours)       |
+------------------------------------------------------------------------------+
| scripted resting will not be blocked!                                        |
+------------------------------------------------------------------------------+
--]]

function GT_TweaksAnthology_LimitRestingMechanic(mode)
	if mode == 0x1 then -- script trigger
		local toReturn = true
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				EEex_Utility_IterateCPtrList(partyMember.m_timedEffectList, function(effect) -- CGameEffect
					if effect.m_sourceRes:get() == "GTRULE01" then
						if effect.m_effectId == 0x152 then -- Disable rest or save (338)
							toReturn = false
							return true -- break loop
						end
					end
				end)
				if not toReturn then break end -- break loop
			end
		end
		return toReturn
	elseif mode == 0x2 then -- script action
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				partyMember:applyEffect({
					["effectID"] = 0x141, -- Remove effects by resource (321)
					["res"] = "GTRULE01",
					["noSave"] = true, -- just in case...
					["sourceID"] = partyMember.m_id,
					["sourceTarget"] = partyMember.m_id,
				})
				--
				partyMember:applyEffect({
					["effectID"] = 0x152, -- Disable rest or save (338)
					["effectAmount"] = %feedback_strref%,
					["duration"] = 7200,
					["m_sourceRes"] = "GTRULE01",
					["noSave"] = true, -- just in case...
					["sourceID"] = partyMember.m_id,
					["sourceTarget"] = partyMember.m_id,
				})
			end
		end
	end
end
