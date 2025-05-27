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
	local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local op12DamageType, ACModifier = GT_Utility_DamageTypeConverter(selectedWeaponAbility.damageType, targetActiveStats)
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
	if not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 0xC, -- Damage
			["dwFlags"] = op12DamageType * 0x10000, -- mode: normal
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
	--
	immunityToDamage:free()
end
