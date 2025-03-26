--[[
+---------------------------------------+
| cdtweaks, NWN-ish Armor vs. Dexterity |
+---------------------------------------+
--]]

-- Apply condition --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual malus
	local apply = function(modifier)
		-- Update tracking var
		sprite:setLocalInt("gtNWNArmorClassMod", modifier)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTRULE00",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 0, -- AC bonus
			["durationType"] = 9,
			["effectAmount"] = modifier,
			["m_sourceRes"] = "GTRULE00",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / stats / race
	local playableRaces = {
		["HUMAN"] = true,
		["ELF"] = true,
		["HALF_ELF"] = true,
		["DWARF"] = true,
		["GNOME"] = true,
		["HALFLING"] = true,
		["HALFORC"] = true,
	}
	--
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
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
	local dexmod = GT_Resource_2DA["dexmod"]
	-- Since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteDEX = sprite.m_derivedStats.m_nDEX
	--
	local AC = tonumber(dexmod[string.format("%s", spriteDEX)]["AC"])
	local modifier
	--
	if armor then
		if armorAnimation == "3A" then -- Chain mail
			modifier = math.floor(AC / 2)
			if modifier == 0 then
				modifier = -1 -- in case the base bonus is ``-1``, ``modifier`` should not be ``0``...
			end
		elseif armorAnimation == "4A" then -- Plate mail
			modifier = AC
		end
	end
	-- if the character is wielding a medium or heavy armor ...
	local applyCondition = playableRaces[spriteRaceStr] and modifier < 0 and armor and armorTypeStr == "ARMOR" and (armorAnimation == "3A" or armorAnimation == "4A")
	--
	if sprite:getLocalInt("gtNWNArmorClassMod") == 0 then
		if applyCondition then
			apply(modifier)
		end
	else
		if applyCondition then
			-- Check if DEX has changed since the last application
			if modifier ~= sprite:getLocalInt("gtNWNArmorClassMod") then
				apply(modifier)
			end
		else
			-- Mark the creature as 'malus removed'
			sprite:setLocalInt("gtNWNArmorClassMod", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE00",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
