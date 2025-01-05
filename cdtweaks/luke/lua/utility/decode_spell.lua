--[[
+-------------------------------------------------------+
| Get ``spellResRef`` from spellID (borrowed from Bubb) |
+-------------------------------------------------------+
--]]

function GT_Utility_DecodeSpell(spellIDS)
	local prefix
	local spellType = math.floor(spellIDS / 1000)
	--
	if spellType == 1 then
		prefix = "SPPR"
	elseif spellType == 2 then
		prefix = "SPWI"
	elseif spellType == 3 then
		prefix = "SPIN"
	elseif spellType == 4 then
		prefix = "SPCL"
	else
		prefix = "MARW"
	end
	--
	return prefix .. string.format("%03d", spellIDS % 1000)
end
