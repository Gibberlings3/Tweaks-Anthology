--[[
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Utility: Lua tables derived from .2DA / .IDS resources (it's not needed per se, but we'll be getting hash map levels of performance instead of linear search) |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

GT_Resource_2DA = {}
GT_Resource_IDSToSymbol = {}
GT_Resource_SymbolToIDS = {}

EEex_GameState_AddInitializedListener(function()
	-- 2DA
	EEex_Utility_NewScope(function()
		local resources = { "STRMOD", "STRMODEX", "DEXMOD", "STYLBONU", "SNEAKATT", "GTABMOD" }
		--
		for _, v in ipairs(resources) do
			local data = EEex_Resource_Load2DA(v)
			local nX, nY = data:getDimensions()
			nX = nX - 2
			nY = nY - 1
			-- Ensure that a table exists for this key
			if GT_Resource_2DA[string.lower(v)] == nil then
				GT_Resource_2DA[string.lower(v)] = {}
			end
			-- Fill in the values
			for rowIndex = 0, nY do
				GT_Resource_2DA[string.lower(v)][data:getRowLabel(rowIndex)] = {} -- Initialize each row
				for columnIndex = 0, nX do
					GT_Resource_2DA[string.lower(v)][data:getRowLabel(rowIndex)][data:getColumnLabel(columnIndex)] = data:getAtPoint(columnIndex, rowIndex)
				end
			end
		end
	end)
	-- IDS
	EEex_Utility_NewScope(function()
		local resources = { "EA", "GENERAL", "RACE", "CLASS", "GENDER", "ALIGN", "ITEMFLAG", "STATE", "STATS", "SPELL" }
		--
		for _, v in ipairs(resources) do
			local data = EEex_Resource_LoadIDS(v)
			-- Ensure that a table exists for this key
			if GT_Resource_IDSToSymbol[string.lower(v)] == nil then
				GT_Resource_IDSToSymbol[string.lower(v)] = {}
			end
			if GT_Resource_SymbolToIDS[string.lower(v)] == nil then
				GT_Resource_SymbolToIDS[string.lower(v)] = {}
			end
			data:iterateUnpackedEntries(function(id, symbol, _)
				GT_Resource_IDSToSymbol[string.lower(v)][id] = symbol
				GT_Resource_SymbolToIDS[string.lower(v)][symbol] = id
			end)
		end
	end)
end)
