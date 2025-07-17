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
		sprite:setLocalInt("gtNWNBaneOfEnemies", raceID)
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
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local m_nHatedRace = sprite.m_derivedStats.m_nHatedRace
	-- any lvl 21+ ranger (single/multi/(complete)dual, not fallen)
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	--
	local applyAbility = isRangerAll and GT_EvalConditional["parseConditionalString"](sprite, sprite, "ClassLevelGT(Myself,WARRIOR,20)") and m_nHatedRace > 0
	--
	if sprite:getLocalInt("gtNWNBaneOfEnemies") == 0 then
		if applyAbility then
			apply(m_nHatedRace)
		end
	else
		if applyAbility then
			-- check if ``m_nHatedRace`` has changed since the last application
			if m_nHatedRace ~= sprite:getLocalInt("gtNWNBaneOfEnemies") then
				apply(m_nHatedRace)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNBaneOfEnemies", 0)
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
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	--
	if selectedWeapon["ability"].type == 1 and sourceSprite.m_leftAttack == 1 then -- if attacking with offhand...
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		local offHand = items:get(9) -- CItem
		--
		if offHand then
			local pHeader = offHand.pRes.pHeader -- Item_Header_st
			local itemTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
			--
			if itemTypeStr ~= "SHIELD" then -- if not shield, then overwrite item ability...
				selectedWeapon["ability"] = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
			end
		end
	end
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	local targetRaceID = CGameSprite.m_typeAI.m_Race
	--
	local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
	--
	if targetRaceID == sourceSprite:getLocalInt("gtNWNBaneOfEnemies") then -- race check
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
	end
end
