--[[
+--------------------------------------------------+
| cdtweaks, NWN Good Aim racial feat for Halflings |
+--------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksGoodAim", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%HALFLING_GOOD_AIM%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 167, -- Missile THAC0 bonus
			["effectAmount"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "%HALFLING_GOOD_AIM%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%HALFLING_GOOD_AIM%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / race
	local equipment = sprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local selectedWeaponHeader = selectedWeapon.pRes.pHeader
	local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	--
	local selectedWeaponTypeStr = GT_Resource_IDSToSymbol["itemcat"][selectedWeaponHeader.itemType]
	-- This feat grants a +1 thac0 bonus with throwing weapons (throwing daggers, throwing axes, darts, throwing hammers)
	local applyAbility = (selectedWeaponTypeStr == "DAGGER" or selectedWeaponTypeStr == "AXE" or selectedWeaponTypeStr == "HAMMER" or selectedWeaponTypeStr == "DART")
		and selectedWeaponAbility.type == 2 -- Ranged
		and spriteRaceStr == "HALFLING"
	--
	if sprite:getLocalInt("cdtweaksGoodAim") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksGoodAim", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%HALFLING_GOOD_AIM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
