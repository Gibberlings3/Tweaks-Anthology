--[[
+------------------------------------------------------------+
| Make sure innate abilities cannot be interrupted by damage |
+------------------------------------------------------------+
--]]

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)

	local m_curAction = sprite.m_curAction -- CAIAction
	local m_scriptName = sprite.m_scriptName:get()

	local actionSources = {
		[31] = true, -- Spell()
		[95] = true, -- SpellPoint()
		[476] = true, -- EEex_SpellObjectOffset()
	}

	local deathvarSources = {
		["gtAnmlCompWolf"] = true,
		["gtAnmlCompFalcon"] = true,
		["gtAnmlCompBear"] = true,
		["gtAnmlCompBoar"] = true,
		["gtAnmlCompLeopard"] = true,
		["gtAnmlCompSnake"] = true,
		["gtAnmlCompBeetle"] = true,
		["gtAnmlCompSpider"] = true,
	}

	local resrefSources = {
		["%INNATE_WINTER_WOLF_FROST_BREATH%"] = true,
		["%INNATE_SNAKE_CHARM%"] = true,
		["%INNATE_SPIDER_WEB_TANGLE%"] = true,
		["%INNATE_ANIMAL_FEROCITY%"] = true,
	}

	if not (deathvarSources[m_scriptName] and actionSources[m_curAction.m_actionID] and resrefSources[resref] and changeAmount < 0) then
		return
	end

	-- morph current action
	if m_curAction.m_actionID == 31 then -- Spell()
		m_curAction.m_actionID = 113 -- ForceSpell()
	else
		m_curAction.m_actionID = 114 -- ForceSpellPoint()
	end

end)
