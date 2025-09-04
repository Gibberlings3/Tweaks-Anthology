--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Trackless Step class feat for Rangers |
+---------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) or not sprite.m_pArea then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("gtNWNTracklessStep", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%RANGER_TRACKLESS_STEP%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 59, -- Move silently bonus
			["durationType"] = 9,
			--["dwFlags"] = 2, -- Percentage Modifier
			["effectAmount"] = 25, -- +25
			["m_sourceRes"] = "%RANGER_TRACKLESS_STEP%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 275, -- Hide in shadows bonus
			["durationType"] = 9,
			--["dwFlags"] = 2, -- Percentage Modifier
			["effectAmount"] = 25, -- +25
			["m_sourceRes"] = "%RANGER_TRACKLESS_STEP%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%RANGER_TRACKLESS_STEP%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's area / class / equipment
	local items = sprite.m_equipment.m_items -- Array<CItem*,39>
	--
	local armor = items:get(1) -- CItem (index from "slots.ids")
	local armorTypeStr
	local armorAnimation
	--
	if armor then -- if the character is equipped with an armor...
		local pHeader = armor.pRes.pHeader -- Item_Header_st
		armorTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
		armorAnimation = EEex_CastUD(pHeader.animationType, "CResRef"):get()
	end
	--
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local isForest = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x4)
	local isOutdoor = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x0)
	--
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	--
	local applyAbility = (isForest and isOutdoor)
		and isRangerAll
		and (not armor or (armorTypeStr == "ARMOR" and armorAnimation ~= "3A" and armorAnimation ~= "4A")) -- light armor / no armor
	--
	if sprite:getLocalInt("gtNWNTracklessStep") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtNWNTracklessStep", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%RANGER_TRACKLESS_STEP%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
