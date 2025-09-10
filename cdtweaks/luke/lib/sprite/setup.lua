--[[
+-------------------------------------------------------------------------------------------+
| Dynamically set some cre stats (f.i. kit abilities, THAC0, saves, ...)                    |
+-------------------------------------------------------------------------------------------+
| Param1 : BIT0 (skip Saves), BIT1 (skip THAC0), BIT2 (skip HPs), BIT3 (skip kit abilities) |
+-------------------------------------------------------------------------------------------+
--]]

function GTSETCRE(CGameEffect, CGameSprite)
	-- class IDS to symbol / saves table mapping (array of tables to support multi/dual/triple classes)
	local mapping = {
		[1] = {{["MAGE"] = "savewiz"}},
		[2] = {{["FIGHTER"] = "savewar"}},
		[3] = {{["CLERIC"] = "saveprs"}},
		[4] = {{["THIEF"] = "saverog"}},
		[5] = {{["BARD"] = "saverog"}},
		[6] = {{["PALADIN"] = "savewar"}},
		[7] = {{["FIGHTER"] = "savewar"}, {["MAGE"] = "savewiz"}},
		[8] = {{["FIGHTER"] = "savewar"}, {["CLERIC"] = "saveprs"}},
		[9] = {{["FIGHTER"] = "savewar"}, {["THIEF"] = "saverog"}},
		[10] = {{["FIGHTER"] = "savewar"}, {["MAGE"] = "savewiz"}, {["THIEF"] = "saverog"}},
		[11] = {{["DRUID"] = "saveprs"}},
		[12] = {{["RANGER"] = "savewar"}},
		[13] = {{["MAGE"] = "savewiz"}, {["THIEF"] = "saverog"}},
		[14] = {{["CLERIC"] = "saveprs"}, {["MAGE"] = "savewiz"}},
		[15] = {{["CLERIC"] = "saveprs"}, {["THIEF"] = "saverog"}},
		[16] = {{["FIGHTER"] = "savewar"}, {["DRUID"] = "saveprs"}},
		[17] = {{["FIGHTER"] = "savewar"}, {["MAGE"] = "savewiz"}, {["CLERIC"] = "saveprs"}},
		[18] = {{["CLERIC"] = "saveprs"}, {["RANGER"] = "savewar"}},
		[19] = {{["SORCERER"] = "savewiz"}},
		[20] = {{["MONK"] = "savemonk"}},
		[21] = {{["SHAMAN"] = "saveprs"}},
	}
	--
	local m_baseStats = CGameSprite.m_baseStats
	--
	local kitIDS = EEex_BOr(EEex_LShift(m_baseStats.m_mageSpecUpperWord, 16), m_baseStats.m_mageSpecialization)
	if kitIDS == 0x0 then
		kitIDS = 0x4000
	end
	--
	local m_Class =  CGameSprite.m_typeAI.m_Class
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	--
	local m_CONBase = m_baseStats.m_CONBase
	local levels = {m_baseStats.m_level1, m_baseStats.m_level2, m_baseStats.m_level3}
	-- single-class / multi-class / dual-class
	local m_flags = m_baseStats.m_flags
	-- Default to fighter if not playable class
	local isPlayableClass = true
	if not (m_Class >= 1 and m_Class <= 21) then
		m_Class = 2
		isPlayableClass = false
	end
	-- dual-class handling
	local originalClass = ""
	if isPlayableClass then
		if EEex_IsBitSet(m_flags, 0x3) then
			originalClass = "FIGHTER"
		elseif EEex_IsBitSet(m_flags, 0x4) then
			originalClass = "MAGE"
		elseif EEex_IsBitSet(m_flags, 0x5) then
			originalClass = "CLERIC"
		elseif EEex_IsBitSet(m_flags, 0x6) then
			originalClass = "THIEF"
		elseif EEex_IsBitSet(m_flags, 0x7) then
			originalClass = "DRUID"
		elseif EEex_IsBitSet(m_flags, 0x8) then
			originalClass = "RANGER"
		end
	end
	-- Set saves
	if EEex_IsBitUnset(CGameEffect.m_effectAmount, 0x0) then
		local death = 20
		local wands = 20
		local poly = 20
		local breath = 20
		local spells = 20
		--
		local conBased
		if spriteRaceStr == "DWARF" or spriteRaceStr == "HALFLING" then
			conBased = GT_Resource_2DA["savecndh"]
		elseif spriteRaceStr == "GNOME" then
			conBased = GT_Resource_2DA["savecng"]
		end
		--
		for i = 1, #mapping[m_Class] do
			for symbol, str in pairs(mapping[m_Class][i]) do
				-- dual-class handling
				if originalClass == "" or symbol ~= originalClass then
					local tbl = GT_Resource_2DA[str]
					--
					death = math.min(death, tonumber(tbl["DEATH"][tostring(levels[i])]))
					wands = math.min(wands, tonumber(tbl["WANDS"][tostring(levels[i])]))
					poly = math.min(poly, tonumber(tbl["POLY"][tostring(levels[i])]))
					breath = math.min(breath, tonumber(tbl["BREATH"][tostring(levels[i])]))
					spells = math.min(spells, tonumber(tbl["SPELL"][tostring(levels[i])]))
				elseif (i == 1 and levels[2] > levels[1]) or (i == 2 and levels[1] > levels[2]) then -- complete dual-class
					local tbl = GT_Resource_2DA[str]
					--
					death = math.min(death, tonumber(tbl["DEATH"][tostring(levels[i])]))
					wands = math.min(wands, tonumber(tbl["WANDS"][tostring(levels[i])]))
					poly = math.min(poly, tonumber(tbl["POLY"][tostring(levels[i])]))
					breath = math.min(breath, tonumber(tbl["BREATH"][tostring(levels[i])]))
					spells = math.min(spells, tonumber(tbl["SPELL"][tostring(levels[i])]))
				end
			end
		end
		--
		if conBased then
			death = death - tonumber(conBased["DEATH"][tostring(m_CONBase)])
			wands = wands - tonumber(conBased["WANDS"][tostring(m_CONBase)])
			poly = poly - tonumber(conBased["POLY"][tostring(m_CONBase)])
			breath = breath - tonumber(conBased["BREATH"][tostring(m_CONBase)])
			spells = spells - tonumber(conBased["SPELL"][tostring(m_CONBase)])
		end
		--
		local effectCodes = {
			{["op"] = 33, ["p1"] = death}, -- save vs. death
			{["op"] = 34, ["p1"] = wands}, -- save vs. wands
			{["op"] = 35, ["p1"] = poly}, -- save vs. polymorph
			{["op"] = 36, ["p1"] = breath}, -- save vs. breath
			{["op"] = 37, ["p1"] = spells}, -- save vs. spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 1,
				["dwFlags"] = 1, -- set
				["effectAmount"] = attributes["p1"] or 0,
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
	end
	-- Set THAC0
	if EEex_IsBitUnset(CGameEffect.m_effectAmount, 0x1) then
		local base = 20
		--
		local thac0 = GT_Resource_2DA["thac0"]
		--
		for i = 1, #mapping[m_Class] do
			for symbol, str in pairs(mapping[m_Class][i]) do
				-- dual-class handling
				if originalClass == "" or symbol ~= originalClass then
					base = math.min(base, tonumber(thac0[symbol][tostring(levels[i])]))
				elseif (i == 1 and levels[2] > levels[1]) or (i == 2 and levels[1] > levels[2]) then -- complete dual-class
					base = math.min(base, tonumber(thac0[symbol][tostring(levels[i])]))
				end
			end
		end
		--
		CGameSprite:applyEffect({
			["effectID"] = 54, -- base THAC0 bonus
			["durationType"] = 1,
			["dwFlags"] = 1, -- set
			["effectAmount"] = base,
			["noSave"] = true,
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
	end
	-- Set HPs
	if EEex_IsBitUnset(CGameEffect.m_effectAmount, 0x2) then
		if isPlayableClass then
			local hpclass = GT_Resource_2DA["hpclass"]
			local kitlist = GT_Resource_2DA["kitlist"]
			-- kitlist.2da / hpclass.2da mismatch
			local kitSymbol = EEex_Resource_KitIDSToSymbol(kitIDS)
			if kitSymbol == "BEASTMASTER" then
				kitSymbol = "BEAST_MASTER"
			end
			--
			local _, rows = EEex_Resource_Get2DADimensions(EEex_Resource_Load2DA("KITLIST"))
			local m_maxHitPointsBase = 0
			--
			for i = 1, #mapping[m_Class] do
				for symbol in pairs(mapping[m_Class][i]) do
					-- dual-class handling
					local start, finish -- start level, end level
					if originalClass == "" or symbol == originalClass then
						start = 1
						finish = levels[i]
					else
						start = i == 1 and (levels[2] + 1) or (levels[1] + 1)
						finish = levels[i]
					end
					-- check if this is a kit of the current class
					local hptbl = hpclass[symbol]["TABLE"]
					for idx = 0, rows - 1 do
						if kitlist[tostring(idx)]["ROWNAME"] == kitSymbol and GT_Resource_IDSToSymbol["class"][kitlist[tostring(idx)]["CLASS"]] == symbol then
							hptbl = hpclass[kitSymbol]["TABLE"]
							break
						end
					end
					--
					if start and finish then -- sanity check
						local data = EEex_Resource_Load2DA(hptbl)
						local nX, nY = data:getDimensions()
						nX = nX - 2
						nY = nY - 1
						-- calculate HPs
						for rowIndex = 0, nY do
							if tonumber(data:getRowLabel(rowIndex)) >= start and tonumber(data:getRowLabel(rowIndex)) <= finish then
								local sides = tonumber(data:getAtPoint(0, rowIndex))
								local rolls = tonumber(data:getAtPoint(1, rowIndex))
								local modifier = tonumber(data:getAtPoint(2, rowIndex))
								--
								m_maxHitPointsBase = m_maxHitPointsBase + (sides * rolls) + modifier
							end
						end
						--
						data:free()
					end
				end
			end
			-- multi-class HP division
			if originalClass == "" and #mapping[m_Class] > 1 then
				m_maxHitPointsBase = math.floor(m_maxHitPointsBase / #mapping[m_Class])
			end
			--
			CGameSprite:applyEffect({
				["effectID"] = 18, -- max HP bonus
				["durationType"] = 1,
				["dwFlags"] = 1, -- set, update current HP
				["effectAmount"] = m_maxHitPointsBase,
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
	end
	-- Apply kit abilities
	if EEex_IsBitUnset(CGameEffect.m_effectAmount, 0x3) then
		if isPlayableClass then
			local str = string.format("AddKit(%d)", kitIDS)
			GT_ExecuteResponse["parseResponseString"](CGameSprite, nil, str)
		end
	end
	-- Terminate this op402 effect
	CGameEffect.m_done = true
end

