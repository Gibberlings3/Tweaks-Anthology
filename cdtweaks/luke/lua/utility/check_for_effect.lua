--[[
+-----------------------------------------------------------------------------------------------------------+
| Check if the specified effect is present on the given sprite                                              |
+-----------------------------------------------------------------------------------------------------------+
| Example usage:                                                                                            |
|      GT_Utility_Sprite_CheckForEffect(CGameSprite, {["op"] = 0x1, ["effsource"] = "GTDUMMY"}) |
+-----------------------------------------------------------------------------------------------------------+
--]]

function GT_Utility_Sprite_CheckForEffect(CGameSprite, table, checkTimed, checkEquiped)
	local found = false  -- default return value

	if checkTimed == nil then
		checkTimed = true  -- default to true if omitted
	elseif type(checkTimed) ~= "boolean" then
		checkTimed = false  -- default to false if not boolean
	end

	if checkEquiped == nil then
		checkEquiped = true
	elseif type(checkEquiped) ~= "boolean" then
		checkEquiped = false
	end

	local check = function(effect)
		if not table["op"] or table["op"] == effect.m_effectId then
			if not table["p1"] or table["p1"] == effect.m_effectAmount then
				if not table["p2"] or table["p2"] == effect.m_dWFlags then
					if not table["res"] or table["res"] == effect.m_res:get() then
						if not table["spec"] or table["spec"] == effect.m_special then
							if not table["effsource"] or table["effsource"] == effect.m_sourceRes:get() then
								found = true
								return true
							end
						end
					end
				end
			end
		end
	end

	if checkTimed then
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, check)
	end

	if not found then
		if checkEquiped then
			EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, check)
		end
	end

	return found
end
