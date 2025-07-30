--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Weapon Finesse class feat for Thieves |
+---------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- Unusually large weapons --
	local unusuallyLargeWeapons = {
		["BDBONE02"] = true, -- Ettin Club +1
	}
	-- internal function that applies the actual bonus
	local apply = function(modifier)
		-- Update tracking var
		sprite:setLocalInt("gtNWNWeaponFinesse", modifier)
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
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeapon["header"].itemType)
	--
	local strmod = GT_Resource_2DA["strmod"]
	local strmodex = GT_Resource_2DA["strmodex"]
	local dexmod = GT_Resource_2DA["dexmod"]
	-- Since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteSTR = sprite.m_derivedStats.m_nSTR
	local spriteSTRExtra = sprite.m_derivedStats.m_nSTRExtra
	local spriteDEX = sprite.m_derivedStats.m_nDEX
	--
	local class = GT_Resource_SymbolToIDS["class"]
	-- compute modifier
	local curStrBonus = spriteSTR == 18 and (tonumber(strmod[string.format("%s", spriteSTR)]["TO_HIT"] + strmodex[string.format("%s", spriteSTRExtra)]["TO_HIT"])) or tonumber(strmod[string.format("%s", spriteSTR)]["TO_HIT"])
	local curDexBonus = tonumber(dexmod[string.format("%s", spriteDEX)]["MISSILE"])
	--
	local modifier = curDexBonus - curStrBonus
	-- any thief (single/multi/(complete)dual)
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	-- if the thief is wielding a small blade / mace / club that scales with STR and "dexmod.2da" is better than "strmod.2da" + "strmodex.2da" ...
	local applyAbility = (selectedWeaponTypeStr == "DAGGER" or selectedWeaponTypeStr == "SMSWORD" or selectedWeaponTypeStr == "MACE")
		and not unusuallyLargeWeapons[selectedWeapon["resref"]]
		and modifier > 0
		and selectedWeapon["ability"].quickSlotType == 1 -- Location: Weapon
		and selectedWeapon["ability"].type == 1 -- Type: Melee
		and (EEex_IsBitSet(selectedWeapon["ability"].abilityFlags, 0x0) or EEex_IsBitSet(selectedWeapon["ability"].abilityFlags, 0x3))
		and isThiefAll
	--
	if sprite:getLocalInt("gtNWNWeaponFinesse") == 0 then
		if applyAbility then
			apply(modifier)
		end
	else
		if applyAbility then
			-- Check if STR/STREx/DEX have changed since the last application
			if modifier ~= sprite:getLocalInt("gtNWNWeaponFinesse") then
				apply(modifier)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtNWNWeaponFinesse", 0)
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
