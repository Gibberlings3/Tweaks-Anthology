--[[
+-------------------------------------------------------------+
| cdtweaks: NWN-ish Animal Companion kit feat for beastmaster |
+-------------------------------------------------------------+
--]]

-- Give/remove feat --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or Infinity_GetCurrentScreenName() == 'CHARGEN' then
		return
	end
	-- internal function that grants the actual feat
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtBeastmasterAnimalCompanion", 1)
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
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- Check if beastmaster -- single/multi/(complete)dual
	local gainAbility = spriteClassStr == "RANGER" or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)) and EEex_IsBitUnset(spriteFlags, 10)
	local gainAbility = gainAbility and spriteKitStr == "BEASTMASTER"
	--
	if sprite:getLocalInt("gtBeastmasterAnimalCompanion") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtBeastmasterAnimalCompanion", 0)
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
