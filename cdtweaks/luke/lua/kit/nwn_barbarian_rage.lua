--[[
+----------------------------------+
| cdtweaks, NWN-ish Barbarian Rage |
+----------------------------------+
--]]

-- Terrifying Rage --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local splstate = GT_Resource_SymbolToIDS["splstate"]
	local stats = GT_Resource_SymbolToIDS["stats"]
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	--
	local isFighterAll = GT_Sprite_CheckIDS(sprite, class["FIGHTER_ALL"], 5)
	--
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtNWNBarbarianRageTimer" then -- dummy opcode that acts as a marker/timer
			found = true
			return true
		end
	end)
	--
	if spriteKitStr == "BARBARIAN" and isFighterAll then
		if EEex_Sprite_GetSpellState(sprite, splstate["BARBARIAN_RAGE"]) then
			if not found then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spl
					["dwFlags"] = 1, -- mode: cast instantly / ignore level
					["res"] = "%BARBARIAN_RAGE%B",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				-- set timer
				sprite:applyEffect({
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_DUMMY_STAT"],
					["m_scriptName"] = "gtNWNBarbarianRageTimer",
					["duration"] = 6,
					["noSave"] = true,
					["m_sourceRes"] = "%BARBARIAN_RAGE%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- Rage / Terrifying Rage / Thundering Rage --

function %BARBARIAN_RAGE%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local gtabmod = GT_Resource_2DA["gtabmod"]
		local conModifier = tonumber(gtabmod[string.format("%s", spriteActiveStats.m_nCON)]["BONUS"])
		--
		local splstate = GT_Resource_SymbolToIDS["splstate"]
		--
		local effectCodes = {
			{["op"] = 328, ["p2"] = splstate["BARBARIAN_RAGE"], ["spec"] = 1}, -- set spell state
			{["op"] = 282, ["p2"] = 3, ["p1"] = 1}, -- modify script state
			{["op"] = 44, ["p1"] = 4}, -- STR mod (+4)
			{["op"] = 10, ["p1"] = 4}, -- CON mod (+4)
			{["op"] = 37, ["p1"] = 2}, -- save vs. spell bonus (+2)
			{["op"] = 0, ["p1"] = -2}, -- AC bonus (-2)
			{["op"] = 341, ["res"] = "%BARBARIAN_RAGE%C", ["spec"] = 1}, -- critical hit effect (melee attacks only, +2d6 extra damage)
			{["op"] = 248, ["res"] = "%BARBARIAN_RAGE%D"}, -- melee hit effect (deafness, 25% chance, no save)
			{["op"] = 142, ["p2"] = 138} -- icon: rage
			{["op"] = 206, ["res"] = CGameEffect.m_sourceRes:get(), ["p1"] = %feedback_strref_already_cast%}, -- protection from spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["special"] = attributes["spec"] or 0,
				["res"] = attributes["res"] or "",
				["duration"] = (6 * 7) + (6 * conModifier),
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
	elseif CGameEffect.m_effectAmount == 2 then -- Terrifying Rage
		local roll = Infinity_RandomNumber(1, 3) -- 1d3
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local panicImmunity = "EEex_IsImmuneToOpcode(Myself,24)"
		--
		if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, panicImmunity) then
			local effectCodes = {}
			--
			if sourceActiveStats.m_nLevel1 > 1 then
				effectCodes = {
					{["op"] = 54, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- base thac0 bonus (-2)
					{["op"] = 325, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- save vs. all bonus (-2)
					{["op"] = 139, ["p1"] = %feedback_strref_trembling_with_fear%, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- string: trembling with fear
					--
					{["op"] = 24, ["dur"] = 6 * roll, ["maxLvl"] = sourceActiveStats.m_nLevel1 - 1}, -- panic
					{["op"] = 142, ["dur"] = 6 * roll, ["p2"] = 36, ["maxLvl"] = sourceActiveStats.m_nLevel1 - 1}, -- icon: panic
					{["op"] = 139, ["p1"] = %feedback_strref_panic%, ["maxLvl"] = sourceActiveStats.m_nLevel1 - 1}, -- string: panic
				}
			else
				effectCodes = {
					{["op"] = 54, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- base thac0 bonus (-2)
					{["op"] = 325, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- save vs. all bonus (-2)
					{["op"] = 139, ["p1"] = %feedback_strref_trembling_with_fear%, ["minLvl"] = sourceActiveStats.m_nLevel1, ["maxLvl"] = sourceActiveStats.m_nLevel1}, -- string: trembling with fear
				}
			end
			--
			local savebonus = math.floor((sourceActiveStats.m_nLevel1 - 1) / 4) -- +1 every 4 levels, starting at 0
			if savebonus > 7 then
				savebonus = 7 -- cap at 7
			end
			--
			for _, attributes in ipairs(effectCodes) do
				CGameSprite:applyEffect({
					["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
					["effectAmount"] = attributes["p1"] or 0,
					["dwFlags"] = attributes["p2"] or 0,
					["duration"] = attributes["dur"] or 0,
					["savingThrow"] = 0x4, -- save vs. death
					["saveMod"] = -1 * savebonus,
					["m_minLevel"] = attributes["minLvl"] or 0,
					["m_maxLevel"] = attributes["maxLvl"] or 0,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		else
			CGameSprite:applyEffect({
				["effectID"] = 139, -- display string
				["effectAmount"] = %feedback_strref_immune%,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	elseif CGameEffect.m_effectAmount == 3 then -- Thundering Rage
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
		--
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		--
		local offHand = items:get(9) -- CItem
		if offHand and sourceSprite.m_leftAttack == 1 then
			local pHeader = offHand.pRes.pHeader -- Item_Header_st
			--
			if EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType) ~= "SHIELD" then -- if not shield, then overwrite item ability...
				selectedWeapon["ability"] = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
			end
		end
		--
		local damageImmunity = "EEex_IsImmuneToOpcode(Myself,12)"
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
		--
		if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, damageImmunity) then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0xC, -- Damage
				["dwFlags"] = damageTypeIDS * 0x10000, -- mode: normal
				["numDice"] = 2,
				["diceSize"] = 6,
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
end
