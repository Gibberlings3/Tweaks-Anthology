--[[
+-----------------------------------------------------+
| cdtweaks, NWN-ish Dual-Wield class feat for Rangers |
+-----------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual penalty
	local apply = function(modifierRight, modifierLeft)
		-- Update tracking vars
		sprite:setLocalInt("gtNWNDualWieldRight", modifierRight)
		sprite:setLocalInt("gtNWNDualWieldLeft", modifierLeft)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%RANGER_DUAL_WIELD%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 306, -- Main-hand THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = modifierRight,
			["m_sourceRes"] = "%RANGER_DUAL_WIELD%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 305, -- Off-hand THAC0 bonus
			["durationType"] = 9,
			["effectAmount"] = modifierLeft,
			["m_sourceRes"] = "%RANGER_DUAL_WIELD%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--[[
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%RANGER_DUAL_WIELD%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--]]
	end
	-- Check creature's equipment / class
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	--
	local items = sprite.m_equipment.m_items -- Array<CItem*,39>
	--
	local armor = items:get(1) -- CItem (index from "slots.ids")
	local armorTypeStr
	local armorAnimation
	--
	if armor then -- if the character is equipped with an armor...
		local pHeader = armor.pRes.pHeader -- Item_Header_st
		armorTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
		armorAnimation = EEex_CastUD(pHeader.animationType, "CResRef"):get() -- certain engine types are nonsensical. We usually create fixups for the bindings whenever we run into them. We'll need to cast the value to properly read them
	end
	--
	local offHand = items:get(9) -- CItem (index from "slots.ids")
	local offHandTypeStr
	--
	if offHand then
		local pHeader = offHand.pRes.pHeader -- Item_Header_st
		offHandTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteProficiency2Weapon = sprite.m_derivedStats.m_nProficiency2Weapon
	-- compute right/left modifiers
	local stylbonu = GT_Resource_2DA["stylbonu"]
	local maxThac0RightPenalty = tonumber(stylbonu["TWOWEAPON-0"]["THAC0_RIGHT"])
	local maxThac0LeftPenalty = tonumber(stylbonu["TWOWEAPON-0"]["THAC0_LEFT"])
	local curThac0RightPenalty = tonumber(stylbonu[string.format("TWOWEAPON-%s", spriteProficiency2Weapon)]["THAC0_RIGHT"])
	local curThac0LeftPenalty = tonumber(stylbonu[string.format("TWOWEAPON-%s", spriteProficiency2Weapon)]["THAC0_LEFT"])
	--
	local modifierRight = curThac0RightPenalty - maxThac0RightPenalty
	local modifierLeft = curThac0LeftPenalty - maxThac0LeftPenalty
	--
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local itemflag = GT_Resource_SymbolToIDS["itemflag"]
	-- If the Ranger is dual-wielding, is equipped with medium or heavy armor, and the bonus is non-zero...
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	--
	local applyAbility = EEex_BAnd(selectedWeapon["header"].itemFlags, itemflag["TWOHANDED"]) == 0
		and selectedWeapon["slot"] ~= 34 -- skip if magically created weapon
		and selectedWeapon["ability"].type == 1 -- type: melee
		and offHand and offHandTypeStr ~= "SHIELD"
		and armor and armorTypeStr == "ARMOR" and (armorAnimation == "3A" or armorAnimation == "4A")
		and isRangerAll -- any ranger (single/multi/(complete)dual, not fallen)
		and (modifierRight ~= 0 or modifierLeft ~= 0)
	--
	if sprite:getLocalInt("gtNWNDualWieldRight") == 0 and sprite:getLocalInt("gtNWNDualWieldLeft") == 0 then
		if applyAbility then
			apply(modifierRight, modifierLeft)
		end
	else
		if applyAbility then
			-- Check if ``m_nProficiency2Weapon`` has changed since the last application
			if modifierRight ~= sprite:getLocalInt("gtNWNDualWieldRight") or modifierLeft ~= sprite:getLocalInt("gtNWNDualWieldLeft") then
				apply(modifierRight, modifierLeft)
			end
		else
			-- Mark the creature as 'malus removed'
			sprite:setLocalInt("gtNWNDualWieldRight", 0)
			sprite:setLocalInt("gtNWNDualWieldLeft", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%RANGER_DUAL_WIELD%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
