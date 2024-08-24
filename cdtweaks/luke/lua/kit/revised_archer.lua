-- cdtweaks, revised archer kit: +X missile thac0/damage bonus with bows only! --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function(bonus)
		-- Update tracking var
		sprite:setLocalInt("cdtweaksRevisedArcherHelper", bonus)
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksRevisedArcher", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDFRLNTD",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 167, -- Missile THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "CDFRLNTD",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 286, -- Missile weapon damage bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "CDFRLNTD",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / class / kit / levels
	local equipment = sprite.m_equipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedItem.pRes.pHeader
	--
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)]
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][itemHeader.itemType]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local bonus = 0
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
	local applyCondition = (selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW")
		and spriteKitStr == "FERALAN"
		and (spriteClassStr == "RANGER"
			-- incomplete dual-class characters are not supposed to benefit from this passive feat
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)))
		and EEex_IsBitUnset(spriteFlags, 10) -- not Fallen Ranger
		and bonus > 0
	--
	if sprite:getLocalInt("cdtweaksRevisedArcher") == 0 then
		if applyCondition then
			apply(bonus)
		end
	else
		if applyCondition then
			-- Check if level has changed since the last application
			if bonus ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper") then
				apply(bonus)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksRevisedArcher", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDFRLNTD",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks, revised archer kit: Called Shot ability (bows only!) --

function GTCLDSHT(CGameEffect, CGameSprite)
	local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	--
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
	--
	if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then -- bow with arrows equipped || bow with unlimited ammo equipped
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 326, -- Apply effects list
			["res"] = "CDCL121",
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end
