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
	local apply = function(value)
		-- Update tracking var
		sprite:setLocalInt("cdtweaksWeaponFinesseHelper", value)
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksWeaponFinesse", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ROGUE_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 306, -- Main-hand THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = value,
			["m_sourceRes"] = "%ROGUE_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%ROGUE_WEAPON_FINESSE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / stats / class
	local equipment = sprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
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
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	--
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local curStrBonus = tonumber(strmod[string.format("%s", spriteSTR)]["TO_HIT"] + strmodex[string.format("%s", spriteSTRExtra)]["TO_HIT"])
	local curDexBonus = tonumber(dexmod[string.format("%s", spriteDEX)]["MISSILE"])
	-- if the thief is wielding a small blade / mace / club that scales with STR and "dexmod.2da" is better than "strmod.2da" + "strmodex.2da" ...
	local applyAbility = (selectedWeaponTypeStr == "DAGGER" or selectedWeaponTypeStr == "SMSWORD" or selectedWeaponTypeStr == "MACE")
		and not cdtweaks_WeaponFinesse_UnusuallyLargeWeapon[selectedWeaponResRef]
		and curDexBonus > curStrBonus
		and selectedWeaponAbility.quickSlotType == 1 -- Location: Weapon
		and selectedWeaponAbility.type == 1 -- Type: Melee
		and (EEex_IsBitSet(selectedWeaponAbility.abilityFlags, 0x0) or EEex_IsBitSet(selectedWeaponAbility.abilityFlags, 0x3))
		and (spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
			-- incomplete dual-class characters are not supposed to benefit from Weapon Finesse
			or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
			or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2)))
	--
	if sprite:getLocalInt("cdtweaksWeaponFinesse") == 0 then
		if applyAbility then
			apply(curDexBonus - curStrBonus)
		end
	else
		if applyAbility then
			-- Check if STR/STREx/DEX have changed since the last application
			if (curDexBonus - curStrBonus) ~= sprite:getLocalInt("cdtweaksWeaponFinesseHelper") then
				apply(curDexBonus - curStrBonus)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksWeaponFinesse", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%ROGUE_WEAPON_FINESSE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
