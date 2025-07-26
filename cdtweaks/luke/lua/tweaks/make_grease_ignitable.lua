--[[
+---------------------------------+
| cdtweaks, Make Grease ignitable |
+---------------------------------+
--]]

-- greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

function GTFLMGRS(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local roll = Infinity_RandomNumber(1, 3) -- 1d3
	--
	local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local fields
	local found = false
	local forceApplyViaOp177 = false
	--
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) then -- Damage (FIRE)
		if string.upper(CGameEffect.m_sourceRes:get()) ~= "GTFLMGRS" then -- prevent infinite loop
			found = true
			fields = GT_Utility_GetEffectFields(CGameEffect)
		end
	elseif CGameEffect.m_effectId == 0xB1 and CGameEffect.m_effectAmount4 ~= 0 then -- https://github.com/Gibberlings3/iesdp/pull/193
		if GT_Sprite_CheckIDS(CGameSprite, CGameEffect.m_effectAmount, CGameEffect.m_dWFlags) then
			local CGameEffectBase = EEex_Resource_Demand(CGameEffect.m_res:get(), "eff")
			-- sanity check
			if CGameEffectBase then
				if CGameEffectBase.m_effectId == 0xC and EEex_IsMaskSet(CGameEffectBase.m_dWFlags, dmgtype["FIRE"]) then -- Damage (FIRE)
					found = true
					forceApplyViaOp177 = true
					fields = GT_Utility_GetEffectFields(CGameEffectBase)
				end
			end
		end
	end
	--
	if found then
		if spriteActiveStats.m_nResistFire < 100 then -- only apply if the target is not immune to fire
			-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
			-- opcodes applied here *should* use the same roll for saves and mr checks...
			-- also, make sure it is *not* deflected/reflected/trapped
			if not GT_Sprite_HasBounceEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {326, 12}, fields["flags"]) or forceApplyViaOp177 then
				if not GT_Sprite_HasImmunityEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {326, 12}, fields["flags"], fields["savingThrow"], 0x0) or forceApplyViaOp177 then
					if not GT_Sprite_HasTrapEffect(CGameSprite, fields["spellLevel"], fields["secondaryType"], fields["flags"]) or forceApplyViaOp177 then
						--
						CGameSprite:applyEffect({
							["effectID"] = 0x146, -- Apply effects list (326)
							--
							["savingThrow"] = EEex_IsBitSet(fields["special"], 0x8) and 0 or fields["savingThrow"], -- ignore save check if the save for half flag is set
							["saveMod"] = fields["saveMod"],
							["m_flags"] = fields["flags"],
							--
							["durationType"] = CGameEffect.m_durationType,
							["duration"] = CGameEffect.m_duration,
							--
							["spellLevel"] = fields["spellLevel"],
							["m_projectileType"] = fields["projectileType"],
							["m_school"] = fields["school"],
							["m_secondaryType"] = fields["secondaryType"],
							["m_sourceRes"] = fields["sourceRes"],
							--
							["m_sourceType"] = fields["sourceType"],
							["m_sourceFlags"] = fields["sourceFlags"],
							["m_casterLevel"] = roll,
							["m_slotNum"] = fields["slotNum"],
							--
							["res"] = "GTFLMGRS",
							--
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				end
			end
		end
	end
end

-- greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual condition
	local apply = function()
		-- Mark the creature as 'condition applied'
		sprite:setLocalInt("gtMakeGreaseIgnitable", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "CDFLMGRS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTFLMGRS", -- Lua func
			["m_sourceRes"] = "CDFLMGRS",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteIsGreased = sprite.m_derivedStats.m_bGrease
	--
	local applyCondition = spriteIsGreased > 0
	--
	if sprite:getLocalInt("gtMakeGreaseIgnitable") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("gtMakeGreaseIgnitable", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDFLMGRS",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
