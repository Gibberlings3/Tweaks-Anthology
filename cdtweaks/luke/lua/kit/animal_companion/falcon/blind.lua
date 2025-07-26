--[[
+---------------------------------------------------------------------------------------+
| Hawk (blind): targeted creature is blinded for 1d10 rounds (save vs. breath to avoid) |
+---------------------------------------------------------------------------------------+
--]]

function %INNATE_HAWK_BLIND%(CGameEffect, CGameSprite)
	local blindDuration = math.random(10) -- 1d10
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	--
	local blindImmunity = "EEex_IsImmuneToOpcode(Myself,74)"
	--
	local levelModifier = math.floor(sourceSprite:getActiveStats().m_nLevel1 / 5) -- +1 every 5 levels
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, blindImmunity) then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 74, -- Duration
			["duration"] = 6 * blindDuration,
			["savingThrow"] = 0x2, -- breath
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_blind%,
			["savingThrow"] = 0x2, -- breath
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
