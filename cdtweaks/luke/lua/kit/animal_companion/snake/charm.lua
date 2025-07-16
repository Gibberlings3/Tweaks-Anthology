--[[
+-------------------------------------------------------------------------------------------+
| Snake Gaze (charm): targeted animal is charmed for 2d6 rounds (save vs. petrify to avoid) |
+-------------------------------------------------------------------------------------------+
--]]

function %INNATE_SNAKE_CHARM%(CGameEffect, CGameSprite)
	local charmDuration = math.random(6) + math.random(6) -- 2d6
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	--
	local charmImmunity = "EEex_IsImmuneToOpcode(Myself,5)"
	--
	local levelModifier = math.floor(sourceSprite:getActiveStats().m_nLevel1 / 5) -- +1 every 5 levels
	--
	if not GT_Trigger_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, charmImmunity) then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 5, -- Charm
			["duration"] = 6 * charmDuration,
			["dwFlags"] = 1, -- Charm type: Charmed (hostile)
			["effectAmount"] = 2, -- Creature type: ANIMAL
			["savingThrow"] = 0x1, -- spell
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 174, -- Play (expiry) sound
			["durationType"] = 4,
			["duration"] = 6 * charmDuration,
			["res"] = "EFF_E04",
			["savingThrow"] = 0x1, -- spell
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
