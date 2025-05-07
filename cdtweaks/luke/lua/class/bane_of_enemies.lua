--[[
+----------------------------------------------------------+
| cdtweaks, NWN-ish Bane of Enemies class feat for Rangers |
+----------------------------------------------------------+
--]]

-- Apply Ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function(raceID)
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtRangerBaneOfEnemies", raceID)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%RANGER_BANE_OF_ENEMIES%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["durationType"] = 9,
			["res"] = "%RANGER_BANE_OF_ENEMIES%", -- EFF file
			["m_sourceRes"] = "%RANGER_BANE_OF_ENEMIES%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 249, -- Ranged hit effect
			["durationType"] = 9,
			["res"] = "%RANGER_BANE_OF_ENEMIES%", -- EFF file
			["m_sourceRes"] = "%RANGER_BANE_OF_ENEMIES%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 178, -- THAC0 vs. type bonus
			["durationType"] = 9,
			["dwFlags"] = 4, -- RACE.IDS
			["effectAmount"] = raceID,
			["special"] = 2, -- +2
			["m_sourceRes"] = "%RANGER_BANE_OF_ENEMIES%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local m_nHatedRace = sprite.m_derivedStats.m_nHatedRace
	-- any lvl 21+ ranger (single/multi/(complete)dual)
	local isRanger = spriteClassStr == "RANGER"
	local isClericRanger = spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)
	local rangerLevel = spriteClassStr == "RANGER" and spriteLevel1 or spriteLevel2
	--
	local applyAbility = (isRanger or isClericRanger) and rangerLevel >= 21 and m_nHatedRace > 0
	--
	if sprite:getLocalInt("gtRangerBaneOfEnemies") == 0 then
		if applyAbility then
			apply(m_nHatedRace)
		end
	else
		if applyAbility then
			-- check if ``m_nHatedRace`` has changed since the last application
			if m_nHatedRace ~= sprite:getLocalInt("gtRangerBaneOfEnemies") then
				apply(m_nHatedRace)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtRangerBaneOfEnemies", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%RANGER_BANE_OF_ENEMIES%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op402 listener (2d6 extra damage) --

function %RANGER_BANE_OF_ENEMIES%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	--
	local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	--
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	if selectedWeaponAbility.type == 1 and sourceSprite.m_leftAttack == 1 then -- if attacking with offhand...
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		local offHand = items:get(9) -- CItem
		--
		if offHand then
			local pHeader = offHand.pRes.pHeader -- Item_Header_st
			local itemTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
			--
			if itemTypeStr ~= "SHIELD" then -- if not shield, then overwrite item ability...
				selectedWeaponAbility = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
			end
		end
	end
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	local targetRaceID = CGameSprite.m_typeAI.m_Race
	--
	local op12DamageType, ACModifier = GT_Utility_DamageTypeConverter(selectedWeaponAbility.damageType, targetActiveStats)
	--
	if targetRaceID == sourceSprite:getLocalInt("gtRangerBaneOfEnemies") then -- race check
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 0xC, -- Damage
			["dwFlags"] = op12DamageType * 0x10000, -- mode: normal
			["numDice"] = 2,
			["diceSize"] = 6,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
