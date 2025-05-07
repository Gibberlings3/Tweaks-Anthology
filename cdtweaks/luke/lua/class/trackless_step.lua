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
		sprite:setLocalInt("gtRangerTracklessStep", 1)
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
			["dwFlags"] = 2, -- Percentage Modifier
			["effectAmount"] = 25, -- +25%
			["m_sourceRes"] = "%RANGER_TRACKLESS_STEP%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 275, -- Hide in shadows bonus
			["durationType"] = 9,
			["dwFlags"] = 2, -- Percentage Modifier
			["effectAmount"] = 25, -- +25%
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
		armorTypeStr = GT_Resource_IDSToSymbol["itemcat"][pHeader.itemType]
		armorAnimation = EEex_CastUD(pHeader.animationType, "CResRef"):get()
	end
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local isForest = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x4)
	local isOutdoor = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x0)
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local applyAbility = (isForest and isOutdoor)
		and (spriteClassStr == "RANGER"
			-- incomplete dual-class characters are not supposed to benefit from this passive feat
			or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x8) or spriteLevel1 > spriteLevel2)))
		-- not fallen rangers
		and EEex_IsBitUnset(spriteFlags, 10)
		-- light armor / no armor
		and (not armor or (armorTypeStr == "ARMOR" and armorAnimation ~= "3A" and armorAnimation ~= "4A"))
	--
	if sprite:getLocalInt("gtRangerTracklessStep") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtRangerTracklessStep", 0)
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
