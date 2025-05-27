--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Weapon Finesse class feat for Thieves |
+---------------------------------------------------------+
--]]

-- Unusually large weapons --

local cdtweaks_WeaponFinesse_UnusuallyLargeWeapon = {
	["BDBONE02"] = true, -- Ettin Club +1
}

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function(modifier)
		-- Update tracking var
		sprite:setLocalInt("gtThiefWeaponFinesse", modifier)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%THIEF_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 306, -- Main-hand THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = modifier,
			["m_sourceRes"] = "%THIEF_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%THIEF_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / stats / class
	local equipment = sprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
	local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeaponHeader.itemType)
	--
	local selectedWeaponResRef = string.upper(selectedWeapon.pRes.resref:get())
	--
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local strmod = GT_Resource_2DA["strmod"]
	local strmodex = GT_Resource_2DA["strmodex"]
	local dexmod = GT_Resource_2DA["dexmod"]
	-- Since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteSTR = sprite.m_derivedStats.m_nSTR
	local spriteSTRExtra = sprite.m_derivedStats.m_nSTRExtra
	local spriteDEX = sprite.m_derivedStats.m_nDEX
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- compute modifier
	local curStrBonus = spriteSTR == 18 and (tonumber(strmod[string.format("%s", spriteSTR)]["TO_HIT"] + strmodex[string.format("%s", spriteSTRExtra)]["TO_HIT"])) or tonumber(strmod[string.format("%s", spriteSTR)]["TO_HIT"])
	local curDexBonus = tonumber(dexmod[string.format("%s", spriteDEX)]["MISSILE"])
	--
	local modifier = curDexBonus - curStrBonus
	-- if the thief is wielding a small blade / mace / club that scales with STR and "dexmod.2da" is better than "strmod.2da" + "strmodex.2da" ...
	local applyAbility = (selectedWeaponTypeStr == "DAGGER" or selectedWeaponTypeStr == "SMSWORD" or selectedWeaponTypeStr == "MACE")
		and not cdtweaks_WeaponFinesse_UnusuallyLargeWeapon[selectedWeaponResRef]
		and modifier > 0
		and selectedWeaponAbility.quickSlotType == 1 -- Location: Weapon
		and selectedWeaponAbility.type == 1 -- Type: Melee
		and (EEex_IsBitSet(selectedWeaponAbility.abilityFlags, 0x0) or EEex_IsBitSet(selectedWeaponAbility.abilityFlags, 0x3))
		and (spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
			-- incomplete dual-class characters are not supposed to benefit from Weapon Finesse
			or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2)))
	--
	if sprite:getLocalInt("gtThiefWeaponFinesse") == 0 then
		if applyAbility then
			apply(modifier)
		end
	else
		if applyAbility then
			-- Check if STR/STREx/DEX have changed since the last application
			if modifier ~= sprite:getLocalInt("gtThiefWeaponFinesse") then
				apply(modifier)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtThiefWeaponFinesse", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%THIEF_WEAPON_FINESSE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
