--[[
+------------------+
| Virtue (cantrip) |
+------------------+
--]]

-- max hp: +1d6 (increment also cur hp if target is at full health, otherwise it could be "abused" to heal yourself...) --

function %CLERIC_VIRTUE%(CGameEffect, CGameSprite)
	local targetMaxHP = CGameSprite:getActiveStats().m_nMaxHitPoints
	local targetCurHP = CGameSprite.m_baseStats.m_hitPoints
	--
	if targetCurHP == targetMaxHP then
		CGameSprite:applyEffect({
			["effectID"] = 18, -- Maximum HP bonus
			["numDice"] = 1,
			["diceSize"] = 6,
			["m_flags"] = 0x3, -- dispellable/bypass mr
			["duration"] = 60,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	else
		CGameSprite:applyEffect({
			["effectID"] = 18, -- Maximum HP bonus
			["numDice"] = 1,
			["diceSize"] = 6,
			["m_flags"] = 0x3, -- dispellable/bypass mr
			["duration"] = 60,
			["dwFlags"] = 3, -- Increment, don't update current HP
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end

