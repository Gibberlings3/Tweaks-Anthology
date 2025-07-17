--[[
+------------------------------------------------------------------+
| Bear (Hug): hit creature suffers extra damage from critical hits |
+------------------------------------------------------------------+
--]]

function %INNATE_BEAR_HUG%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
	local sourceClassStr = GT_Resource_IDSToSymbol["class"][sourceSprite.m_typeAI.m_Class]
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	--
	local conditionalString = "EEex_IsImmuneToOpcode(Myself,12)"
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
	--
	local levelModifier = math.floor(sourceActiveStats.m_nLevel1 / 5) -- +1 every 5 levels
	--
	local diceSize
	local numDice
	if sourceClassStr == "BEAR_BLACK" then
		numDice = 2
		diceSize = 4
	elseif sourceClassStr == "BEAR_BROWN" then
		numDice = 2
		diceSize = 6
	elseif sourceClassStr == "BEAR_CAVE" then
		numDice = 2
		diceSize = 8
	elseif sourceClassStr == "BEAR_POLAR" then
		numDice = 3
		diceSize = 6
	end
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, conditionalString) then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 0xC, -- Damage
			["dwFlags"] = damageTypeIDS * 0x10000, -- mode: normal
			["numDice"] = numDice + levelModifier,
			["diceSize"] = diceSize,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	else
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 324, -- Immunity to resource and message
			["res"] = CGameEffect.m_sourceRes:get(),
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
