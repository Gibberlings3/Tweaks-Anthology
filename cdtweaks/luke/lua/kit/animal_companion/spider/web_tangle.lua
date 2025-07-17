--[[
+--------------------------------------------------------------------------------------------+
| Web Tangle (spider): targeted creature is webbed for 2d6 rounds (save vs. breath to avoid) |
+--------------------------------------------------------------------------------------------+
--]]

function %INNATE_SPIDER_WEB_TANGLE%(CGameEffect, CGameSprite)
	local webDuration = math.random(6) + math.random(6) -- 2d6
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	--
	local webImmunity = "EEex_IsImmuneToOpcode(Myself,157)"
	--
	local levelModifier = math.floor(sourceSprite:getActiveStats().m_nLevel1 / 5) -- +1 every 5 levels
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, webImmunity) then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 157, -- Web overlay
			["duration"] = 6 * webDuration,
			["savingThrow"] = 0x2, -- breath
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 142, -- Display portrait icon
			["dwFlags"] = 129, -- webbed
			["duration"] = 6 * webDuration,
			["savingThrow"] = 0x2, -- breath
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 174, -- Play sound
			["res"] = "CRE_M02",
			["savingThrow"] = 0x2, -- breath
			["saveMod"] = -1 * levelModifier,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
