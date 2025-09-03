--[[
+-------------------------------------------------------------+
| cdtweaks: NWN-ish Animal Companion kit feat for beastmaster |
+-------------------------------------------------------------+
--]]

-- Give/remove feat --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or GT_Globals_IsChargenOrStartMenu[Infinity_GetCurrentScreenName()] then
		return
	end
	-- internal function that grants the actual feat
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNAnimalCompanion", 1)
		--
		sprite:applyEffect({
			["effectID"] = 172, -- Remove spell
			["res"] = "%BEASTMASTER_ANIMAL_COMPANION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 171, -- Give spell
			["res"] = "%BEASTMASTER_ANIMAL_COMPANION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- Check if beastmaster -- single/multi/(complete)dual
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	local isBeastmaster = spriteKitStr == "BEASTMASTER"
	--
	local gainAbility = isRangerAll and isBeastmaster
	--
	if sprite:getLocalInt("gtNWNAnimalCompanion") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNAnimalCompanion", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- Remove spell
				["res"] = "%BEASTMASTER_ANIMAL_COMPANION%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
