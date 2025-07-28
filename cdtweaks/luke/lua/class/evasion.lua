--[[
+-------------------------------------------------------+
| cdtweaks, NWN Evasion class feat for Monks and Rogues |
+-------------------------------------------------------+
--]]

-- Whenever a save vs. breath is allowed for half damage, the character instead takes no damage if he succeeds at the save --
-- [!] op177 is weird and "drives" the EFF file instead of going through the normal effect application process, where EEex's hook is --
-- [!] that is to say, if ``parameter5`` is non-zero (https://github.com/Gibberlings3/iesdp/pull/193), then op403 cannot "see" the specified EFF file (and thus alter it) --
-- [!] guess we are fine with that, since it is supposed to bypass all immunities/checks... --

function %MONK_ROGUE_EVASION%(op403CGameEffect, CGameEffect, CGameSprite)

	if CGameEffect.m_effectId == 0xC and EEex_IsBitSet(CGameEffect.m_savingThrow, 0x1) and EEex_IsBitSet(CGameEffect.m_special, 0x8) then -- Damage (save vs. breath for half)
		local fields = GT_Utility_GetEffectFields(CGameEffect)

		-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
		if not GT_Sprite_HasBounceEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {12}, fields["flags"]) then
			if not GT_Sprite_HasImmunityEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {12}, fields["flags"], fields["savingThrow"], 0x0) then
				if not GT_Sprite_HasTrapEffect(CGameSprite, fields["spellLevel"], fields["secondaryType"], fields["flags"]) then

					-- alter it
					CGameEffect.m_special = EEex_UnsetBit(CGameEffect.m_special, 0x8) -- Remove the "save for half" flag
					CGameEffect.m_special = EEex_SetBit(CGameEffect.m_special, 0x9) -- Set the "fail for half" flag

					-- display some feedback
					local effectCodes = {
						{["op"] = 139, ["p1"] = %feedback_strref_half_damage%, ["stype"] = fields["savingThrow"], ["sbonus"] = fields["saveMod"], ["rd"] = fields["flags"]}, -- display string
						{["op"] = 206, ["res"] = "%MONK_ROGUE_EVASION%B", ["p1"] = -1, ["stype"] = fields["savingThrow"], ["sbonus"] = fields["saveMod"], ["rd"] = fields["flags"]}, -- protection from spell
						{["op"] = 139, ["p1"] = %feedback_strref_no_damage%, ["rd"] = fields["flags"]}, -- display string
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
	local class = GT_Resource_SymbolToIDS["class"]
	-- single/multi/(complete)dual rogues
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	-- monks
	local isMonk = GT_Sprite_CheckIDS(sprite, class["MONK"], 5)
	--
	local applyAbility = isMonk or isThiefAll
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
