--[[
+------------------------------------------------------------------------------------+
| cdtweaks, make infravision useful (-4 to hit in darkness (Dungeon or night areas)) |
+------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and GT_Sprite_IsPartyMember(sprite) and sprite.m_pArea) then
		return
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
	--
	local racefeat = GT_Resource_2DA["racefeat"]
	--
	local isDungeon = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x5)
	local isOutdoor = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x0)
	local isDayNight = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x1)
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime % 0x1A5E0 -- 0d108000 (FIFTEEN_DAYS)
	local isNight = m_gameTime >= 99000 or m_gameTime <= 26999
	--
	local everyone = EEex_Area_GetAllOfTypeInRange(sprite.m_pArea, sprite.m_pos.x, sprite.m_pos.y, GT_AI_ObjectType["ANYONE"], 0x7FFF, false, nil, nil)
	--
	for _, itrSprite in ipairs(everyone) do
		-- Check creature's race / state
		local itrSpriteRaceStr = GT_Resource_IDSToSymbol["race"][itrSprite.m_typeAI.m_Race]
		local hasInnateInfravision = racefeat[itrSpriteRaceStr] and tonumber(racefeat[itrSpriteRaceStr]["VALUE"]) == 1 or false
		--
		local itrSpriteGeneralState = itrSprite:getActiveStats().m_generalState
		--
		local applyCondition = playableRaces[itrSpriteRaceStr] and not (hasInnateInfravision or EEex_IsBitSet(itrSpriteGeneralState, 17)) and (isDungeon or (isOutdoor and isDayNight and isNight))
		--
		if itrSprite:getLocalInt("gtMakeInfravisionUseful") == 0 then
			if applyCondition then
				-- Mark the creature as 'condition applied'
				itrSprite:setLocalInt("gtMakeInfravisionUseful", 1)
				--
				local effectCodes = {
					{["op"] = 321, ["res"] = "GTRULE02"}, -- Remove effects by resource
					{["op"] = 54, ["p1"] = -4}, -- Base thac0 bonus
					{["op"] = 142, ["p2"] = %feedback_icon%}, -- Display portrait icon
				}
				--
				for _, attributes in ipairs(effectCodes) do
					itrSprite:applyEffect({
						["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["durationType"] = 9,
						["res"] = attributes["res"] or "",
						["m_sourceRes"] = "GTRULE02",
						["sourceID"] = itrSprite.m_id,
						["sourceTarget"] = itrSprite.m_id,
						["noSave"] = true, -- just in case
					})
				end
			end
		else
			if applyCondition then
				-- do nothing
			else
				-- Mark the creature as 'condition removed'
				itrSprite:setLocalInt("gtMakeInfravisionUseful", 0)
				--
				itrSprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["res"] = "GTRULE02",
					["sourceID"] = itrSprite.m_id,
					["sourceTarget"] = itrSprite.m_id,
					["noSave"] = true, -- just in case
				})
			end
		end
	end
end)

