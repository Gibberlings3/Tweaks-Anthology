--[[
+------------------------------------------------------------+
| Leopard: Can automatically hide in shadows in forest areas |
+------------------------------------------------------------+
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
		sprite:setLocalInt("gtCatStealthBonus", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%INNATE_CAT_STEALTH_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 59, -- Move silently bonus
			["durationType"] = 9,
			["dwFlags"] = 0x2, -- Percentage Modifier
			["effectAmount"] = 300, -- +300% bonus
			["m_sourceRes"] = "%INNATE_CAT_STEALTH_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 275, -- Hide in shadows bonus
			["durationType"] = 9,
			["dwFlags"] = 0x2, -- Percentage Modifier
			["effectAmount"] = 300, -- +300% bonus
			["m_sourceRes"] = "%INNATE_CAT_STEALTH_BONUS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's area / script name
	local isForest = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x4)
	local isOutdoor = EEex_IsBitSet(sprite.m_pArea.m_header.m_areaType, 0x0)
	--
	local m_scriptName = sprite.m_scriptName:get()
	--
	local applyAbility = (isForest and isOutdoor) and (m_scriptName == "gtNWNAnmlCompLeopard")
	--
	if sprite:getLocalInt("gtCatStealthBonus") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtCatStealthBonus", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%INNATE_CAT_STEALTH_BONUS%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

