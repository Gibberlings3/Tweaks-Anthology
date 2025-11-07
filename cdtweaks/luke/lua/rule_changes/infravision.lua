--[[
+------------------------------------------------------------------------------------+
| cdtweaks, make infravision useful (-4 to hit in darkness (Dungeon or night areas)) |
+------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and sprite.m_pArea) then
		return
	end
	--
	if not EEex_GameObject_Get(EEex_Area_GetVariableInt(sprite.m_pArea, "gtRandomAreaSpriteID")) then
		EEex_Area_SetVariableInt(sprite.m_pArea, "gtRandomAreaSpriteID", sprite.m_id)
	end
	--
	if sprite.m_id ~= EEex_Area_GetVariableInt(sprite.m_pArea, "gtRandomAreaSpriteID") then
		return
	end
	--
	sprite:applyEffect({
		["effectID"] = 0x92, -- Cast spell (146)
		["dwFlags"] = 1, -- Cast instantly (caster level)
		["res"] = "GTRULE02",
		["sourceID"] = sprite.m_id,
		["sourceTarget"] = sprite.m_id,
		["noSave"] = true, -- just in case
	})
end)

-- Op402 listener --

function GTRULE02(CGameEffect, CGameSprite)
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
	local isDungeon = EEex_IsBitSet(CGameSprite.m_pArea.m_header.m_areaType, 0x5)
	local isOutdoor = EEex_IsBitSet(CGameSprite.m_pArea.m_header.m_areaType, 0x0)
	local isDayNight = EEex_IsBitSet(CGameSprite.m_pArea.m_header.m_areaType, 0x1)
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime % 0x1A5E0 -- 0d108000 (FIFTEEN_DAYS)
	local isNight = m_gameTime >= 99000 or m_gameTime <= 26999
	-- Check creature's race / state
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local hasInnateInfravision = racefeat[spriteRaceStr] and tonumber(racefeat[spriteRaceStr]["VALUE"]) == 1 or false
	--
	local spriteGeneralState = CGameSprite:getActiveStats().m_generalState
	--
	local applyCondition = playableRaces[spriteRaceStr] and not (hasInnateInfravision or EEex_IsBitSet(spriteGeneralState, 17)) and (isDungeon or (isOutdoor and isDayNight and isNight))
	--
	if CGameSprite:getLocalInt("gtMakeInfravisionUseful") == 0 then
		if applyCondition then
			-- Mark the creature as 'condition applied'
			CGameSprite:setLocalInt("gtMakeInfravisionUseful", 1)
			--
			local effectCodes = {
				{["op"] = 0x141, ["res"] = "GTRULE02"}, -- Remove effects by resource (321)
				{["op"] = 0x36, ["p1"] = -4}, -- Base thac0 bonus (54)
				{["op"] = 0x8E, ["p2"] = %feedback_icon%}, -- Display portrait icon (142)
			}
			--
			for _, attributes in ipairs(effectCodes) do
				CGameSprite:applyEffect({
					["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
					["effectAmount"] = attributes["p1"] or 0,
					["dwFlags"] = attributes["p2"] or 0,
					["durationType"] = 9,
					["res"] = attributes["res"] or "",
					["m_sourceRes"] = "GTRULE02",
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
					["noSave"] = true, -- just in case
				})
			end
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			CGameSprite:setLocalInt("gtMakeInfravisionUseful", 0)
			--
			CGameSprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE02",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
				["noSave"] = true, -- just in case
			})
		end
	end
end

