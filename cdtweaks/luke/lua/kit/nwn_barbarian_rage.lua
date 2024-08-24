-- cdtweaks, NWN-ish Barbarian Rage (Terrifying Rage) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local enraged = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("cdtweaksTerrifyingRage","LOCALS") \n CheckSpellState(Myself,BARBARIAN_RAGE)')
	local terrifyingRage = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksTerrifyingRage","LOCALS",6) \n ReallyForceSpellRES("CDCL152A",Myself)')
	--
	if enraged:evalConditionalAsAIBase(sprite) then
		terrifyingRage:executeResponseAsAIBaseInstantly(sprite)
	end
	--
	enraged:free()
	terrifyingRage:free()
end)

-- cdtweaks, NWN-ish Barbarian Rage (Rage / Terrifying Rage / Thundering Rage) --

function GTBARBRG(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		local spriteCon = CGameSprite.m_derivedStats.m_nCON + CGameSprite.m_bonusStats.m_nCON
		local conModifier = math.floor((spriteCon - 10) / 2)
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
			{["op"] = 341, ["res"] = "CDCL152B", ["spec"] = 1}, -- critical hit effect (melee attacks only, +2d6 extra damage)
			{["op"] = 248, ["res"] = "CDCL152C"}, -- melee hit effect (deafness, 25% chance)
			{["op"] = 142, ["p2"] = 138} -- icon: rage
			{["op"] = 206, ["res"] = CGameEffect.m_sourceRes:get(), ["p1"] = %feedback_strref_alreadyCast%}, -- protection from spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
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
		local roll = Infinity_RandomNumber(1, 3)
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceLevel1 = sourceSprite.m_derivedStats.m_nLevel1 + sourceSprite.m_bonusStats.m_nLevel1
		--
		local found = false
		local immunityToFear = function(effect)
			if effect.m_effectId == 0x65 and effect.m_dWFlags == 24 then
				found = true
				return true
			end
		end
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, immunityToFear)
		if not found then
			EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, immunityToFear)
		end
		--
		if not found then
			local effectCodes = {}
			--
			if sourceLevel1 > 1 then
				effectCodes = {
					{["op"] = 54, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- base thac0 bonus (-2)
					{["op"] = 325, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- save vs. all bonus (-2)
					{["op"] = 139, ["p1"] = %feedback_strref_tremblingWithFear%, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- string: trembling with fear
					--
					{["op"] = 24, ["dur"] = 6 * roll, ["maxLvl"] = sourceLevel1 - 1}, -- panic
					{["op"] = 142, ["dur"] = 6 * roll, ["p2"] = 36, ["maxLvl"] = sourceLevel1 - 1}, -- icon: panic
					{["op"] = 139, ["p1"] = %feedback_strref_panic%, ["maxLvl"] = sourceLevel1 - 1}, -- string: panic
				}
			else
				effectCodes = {
					{["op"] = 54, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- base thac0 bonus (-2)
					{["op"] = 325, ["dur"] = 6 * roll, ["p1"] = -2, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- save vs. all bonus (-2)
					{["op"] = 139, ["p1"] = %feedback_strref_tremblingWithFear%, ["minLvl"] = sourceLevel1, ["maxLvl"] = sourceLevel1}, -- string: trembling with fear
				}
			end
			--
			local savebonus = math.floor((sourceLevel1 - 1) / 4) -- +1 every 4 levels, starting at 0
			if savebonus > 7 then
				savebonus = 7 -- cap at 7
			end
			--
			for _, attributes in ipairs(effectCodes) do
				CGameSprite:applyEffect({
					["effectID"] = attributes["op"] or -1,
					["effectAmount"] = attributes["p1"] or 0,
					["dwFlags"] = attributes["p2"] or 0,
					["duration"] = attributes["dur"] or 0,
					["savingThrow"] = 0x4, -- save vs. death
					["saveMod"] = -1 * savebonus,
					["m_minLevel"] = attributes["minLvl"],
					["m_maxLevel"] = attributes["maxLvl"],
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
		local itemflag = GT_Resource_SymbolToIDS["itemflag"]
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		local offHand = items:get(9) -- CItem
		if EEex_BAnd(selectedWeaponHeader.itemFlags, itemflag["TWOHANDED"]) == 0 and offHand and sourceSprite.m_leftAttack == 1 then
			local offHandHeader = offHand.pRes.pHeader -- Item_Header_st
			if not (offHandHeader.itemType == 0xC) then -- if not shield, then overwrite item ability...
				selectedWeaponAbility = EEex_Resource_GetItemAbility(offHandHeader, 0) -- Item_ability_st
			end
		end
		--
		local randomValue = math.random(0, 1)
		local damageType = {0x10, 0x0, 0x100, 0x80, 0x800, 0x10 * randomValue, randomValue == 0 and 0x10 or 0x100, 0x100 * randomValue} -- piercing, crushing, slashing, missile, non-lethal, piercing/crushing, piercing/slashing, slashing/crushing
		if damageType[selectedWeaponAbility.damageType] then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 12, -- Damage
				["dwFlags"] = damageType[selectedWeaponAbility.damageType] * 0x10000, -- Normal
				["numDice"] = 2,
				["diceSize"] = 6,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
