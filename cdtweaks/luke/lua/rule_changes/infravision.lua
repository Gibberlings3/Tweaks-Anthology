--[[
+------------------------------------------------------------------------------------+
| cdtweaks, make infravision useful (-4 to hit in darkness (Dungeon or night areas)) |
+------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or not sprite.m_pArea then
		return
	end
	-- internal function that applies the actual penalty
	local apply = function()
		-- Mark the creature as 'condition applied'
		sprite:setLocalInt("gtMakeInfravisionUseful", 1)
		--
		local effectCodes = {
			{["op"] = 321, ["res"] = "GTRULE02"}, -- Remove effects by resource
			{["op"] = 54, ["p1"] = -4}, -- Base thac0 bonus
			{["op"] = 142, ["p2"] = %feedback_icon%}, -- Display portrait icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["m_sourceRes"] = "GTRULE02",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	local playableRaces = {
		["HUMAN"] = true,
		["ELF"] = true,
		["HALF_ELF"] = true,
		["DWARF"] = true,
		["GNOME"] = true,
		["HALFLING"] = true,
		["HALFORC"] = true,
	}
	-- Check creature's race / state
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local racefeat = GT_Resource_2DA["racefeat"]
	local hasInnateInfravision = racefeat[spriteRaceStr] and tonumber(racefeat[spriteRaceStr]["VALUE"]) == 1 or false
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	--
	local isDungeon = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x5)
	local isOutdoor = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x0)
	local isDayNight = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x1)
	--local isNight = EEex_Trigger_ParseConditionalString('TimeOfDay(NIGHT)')
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime % 0x1A5E0 -- 0d108000 (FIFTEEN_DAYS)
	local isNight = m_gameTime >= 99000 or m_gameTime <= 26999
	--
	local applyCondition = playableRaces[spriteRaceStr] and not (hasInnateInfravision or EEex_IsBitSet(spriteGeneralState, 17)) and (isDungeon or (isOutdoor and isDayNight and isNight))
	--
	if sprite:getLocalInt("gtMakeInfravisionUseful") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("gtMakeInfravisionUseful", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE02",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	--
	--isNight:free()
end)
