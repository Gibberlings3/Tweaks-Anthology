--[[
+------------------------------------------------------+
| cdtweaks, NWN-ish Poison Save kit feat for Assassins |
+------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtAssassinPoisonSave", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ASSASSIN_POISON_SAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTIMMUNE", -- lua function
			["effectAmount"] = 0x84, -- BIT2 | BIT7
			["special"] = 1,
			["m_sourceRes"] = "%ASSASSIN_POISON_SAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%ASSASSIN_POISON_SAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit
	local spriteFlags = sprite.m_baseStats.m_flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- single/multi/(complete)dual assassins
	local applyAbility = spriteClassStr == "THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	local applyAbility = applyAbility and spriteKitStr == "ASSASIN" -- typo in kit.ids / kitlist.2da
	--
	if sprite:getLocalInt("gtAssassinPoisonSave") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtAssassinPoisonSave", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%ASSASSIN_POISON_SAVE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
