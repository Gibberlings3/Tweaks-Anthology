--[[
+-------------------------------------------------------+
| cdtweaks, NWN Evasion class feat for Monks and Rogues |
+-------------------------------------------------------+
--]]

-- Whenever a save vs. breath is allowed for half damage, the character instead takes no damage if he succeeds at the save --

function %MONK_ROGUE_EVASION%(op403CGameEffect, CGameEffect, CGameSprite)

	if CGameEffect.m_effectId == 0xC and EEex_IsBitSet(CGameEffect.m_savingThrow, 0x1) and EEex_IsBitSet(CGameEffect.m_special, 0x8) then -- Damage (save vs. breath for half)

		CGameEffect.m_special = EEex_UnsetBit(CGameEffect.m_special, 0x8) -- Remove the "save for half" flag
		CGameEffect.m_special = EEex_SetBit(CGameEffect.m_special, 0x9) -- Set the "fail for half" flag

		-- display some feedback
		local effectCodes = {
			{["op"] = 139, ["p1"] = %feedback_strref_half_damage%, ["stype"] = CGameEffect.m_savingThrow, ["sbonus"] = CGameEffect.m_saveMod, ["rd"] = CGameEffect.m_flags}, -- display string
			{["op"] = 206, ["res"] = "%MONK_ROGUE_EVASION%B", ["p1"] = -1, ["stype"] = CGameEffect.m_savingThrow, ["sbonus"] = CGameEffect.m_saveMod, ["rd"] = CGameEffect.m_flags}, -- protection from spell
			{["op"] = 139, ["p1"] = %feedback_strref_no_damage%, ["rd"] = CGameEffect.m_flags}, -- display string
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["res"] = attributes["res"] or "",
				["savingThrow"] = attributes["stype"] or 0,
				["saveMod"] = attributes["sbonus"] or 0,
				["m_flags"] = attributes["rd"] or 0,
				["m_sourceRes"] = "%MONK_ROGUE_EVASION%B",
				["m_sourceType"] = 1, -- spl
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end

	end
end

-- apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNEvasion", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%MONK_ROGUE_EVASION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%MONK_ROGUE_EVASION%", -- lua function
			["m_sourceRes"] = "%MONK_ROGUE_EVASION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit
	local spriteFlags = sprite.m_baseStats.m_flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- single/multi/(complete)dual rogues
	local isRogue = spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	-- monks
	local isMonk = spriteClassStr == "MONK"
	--
	local applyAbility = isMonk or isRogue
	--
	if sprite:getLocalInt("gtNWNEvasion") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNEvasion", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%MONK_ROGUE_EVASION%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
