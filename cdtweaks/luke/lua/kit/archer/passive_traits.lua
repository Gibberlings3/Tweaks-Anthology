--[[
+-----------------------------------------------------------------------------+
| cdtweaks, Revised Archer Kit (+X missile thac0/damage bonus with bows only) |
+-----------------------------------------------------------------------------+
--]]

-- Apply bonus --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function(bonus)
		-- Update tracking var
		sprite:setLocalInt("gtArcherKitBonus", bonus)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ARCHER_KIT_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 167, -- Missile THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "%ARCHER_KIT_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 286, -- Missile weapon damage bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "%ARCHER_KIT_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / class / kit / levels
	local equipment = sprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeaponHeader.itemType)
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	--
	local bonus = 0
	--
	if spriteClassStr == "RANGER" then
		if spriteLevel1 <= 18 then
			bonus = math.floor(spriteLevel1 / 3)
		else
			bonus = math.floor((spriteLevel1 - 18) / 5) + (18 / 3)
		end
	else
		if spriteLevel2 <= 18 then
			bonus = math.floor(spriteLevel2 / 3)
		else
			bonus = math.floor((spriteLevel2 - 18) / 5) + (18 / 3)
		end
	end
	-- (Bow with arrows equipped || bow with unlimited ammo equipped) && Archer kit
	local applyAbility = (selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW")
		and spriteKitStr == "FERALAN"
		and (spriteClassStr == "RANGER"
			-- incomplete dual-class characters are not supposed to benefit from this passive feat
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)))
		and EEex_IsBitUnset(spriteFlags, 10) -- not Fallen Ranger
		and bonus > 0
	--
	if sprite:getLocalInt("gtArcherKitBonus") == 0 then
		if applyAbility then
			apply(bonus)
		end
	else
		if applyAbility then
			-- Check if level has changed since the last application
			if bonus ~= sprite:getLocalInt("gtArcherKitBonus") then
				apply(bonus)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtArcherKitBonus", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%ARCHER_KIT_BONUS%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
