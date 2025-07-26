--[[
+------------------------+
| Sacred Flame (cantrip) |
+------------------------+
--]]

-- default: 1d6, elemental: 1d4, undead: 1d8, demonic: 1d10 --

function %CLERIC_SACRED_FLAME%(CGameEffect, CGameSprite)
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
	--
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local elemental = {
		["ELEMENTAL"] = true,
		["SALAMANDER"] = true,
		["GENIE"] = true,
		["GITHYANKI"] = true,
	}
	local undead = {
		["UNDEAD"] = true,
	}
	local demonic = {
		["DEMONIC"] = true,
		["IMP"] = true,
		["MEPHIT"] = true,
	}
	--
	local diceSize = 6
	if undead[targetGeneralStr] then
		diceSize = 8
	elseif elemental[targetRaceStr] then
		diceSize = 4
	elseif demonic[targetRaceStr] then
		diceSize = 10
	end
	--
	CGameSprite:applyEffect({
		["effectID"] = 0xC, -- Damage
		["dwFlags"] = dmgtype["MAGIC"],
		["numDice"] = 1,
		["diceSize"] = diceSize,
		["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
		["m_sourceType"] = CGameEffect.m_sourceType,
		["sourceID"] = CGameEffect.m_sourceId,
		["sourceTarget"] = CGameEffect.m_sourceTarget,
	})
end

