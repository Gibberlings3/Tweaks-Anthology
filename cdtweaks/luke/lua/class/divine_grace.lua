--[[
+--------------------------------------------------------+
| cdtweaks, NWN-ish Divine Grace class feat for Paladins |
+--------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function(bonus)
		-- Update tracking var
		sprite:setLocalInt("gtNWNDivineGrace", bonus)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%PALADIN_DIVINE_GRACE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 325, -- All saving throws bonus
			["durationType"] = 9,
			["effectAmount"] = bonus,
			["m_sourceRes"] = "%PALADIN_DIVINE_GRACE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon_paladin%,
			["m_sourceRes"] = "%PALADIN_DIVINE_GRACE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags / CHR
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteCharisma = sprite.m_derivedStats.m_nCHR
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	--
	local gtabmod = GT_Resource_2DA["gtabmod"]
	local bonus = tonumber(gtabmod[string.format("%s", spriteCharisma)]["BONUS"])
	-- The paladin adds its charisma bonus (if positive) to all saving throws (provided it is not fallen)
	local applyAbility = spriteClassStr == "PALADIN" and spriteKitStr ~= "Blackguard" and bonus and bonus > 0 and EEex_IsBitUnset(spriteFlags, 0x9)
	--
	if sprite:getLocalInt("gtNWNDivineGrace") == 0 then
		if applyAbility then
			apply(bonus)
		end
	else
		if applyAbility then
			-- Check if Charisma has changed since the last application
			if bonus ~= sprite:getLocalInt("gtNWNDivineGrace") then
				apply(bonus)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtNWNDivineGrace", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%PALADIN_DIVINE_GRACE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
