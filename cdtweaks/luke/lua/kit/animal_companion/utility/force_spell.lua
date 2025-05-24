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
		["%INNATE_SNAKE_GRASP%"] = true,
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

	-- restore memorization bit (make it castable at will)
	if resref == "%INNATE_SNAKE_CHARM%" then

		local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
		local memList = spellLevelMemListArray:getReference(0) -- *count starts from 0*

		EEex_Utility_IterateCPtrList(memList, function(memInstance)
			local memInstanceResref = memInstance.m_spellId:get()
			if memInstanceResref == resref then
				local memFlags = memInstance.m_flags
				if EEex_IsBitUnset(memFlags, 0x0) then
					memInstance.m_flags = EEex_SetBit(memFlags, 0x0)
					return true
				end
			end
		end)
	end

end)
