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
	local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
	--
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) then -- Damage (FIRE)
		if string.upper(CGameEffect.m_sourceRes:get()) ~= "GTFLMGRS" then -- prevent infinite loop
			if spriteActiveStats.m_nResistFire < 100 then -- only apply if the target is not immune to fire
				if not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
					-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
					-- opcodes applied here *should* use the same roll for saves and mr checks...
					-- also, make sure it is *not* reflected
					if not GT_Sprite_HasBounceEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {326}, CGameEffect.m_flags) then
						CGameSprite:applyEffect({
							["effectID"] = 0x146, -- Apply effects list (326)
							--
							["savingThrow"] = EEex_IsBitSet(CGameEffect.m_special, 0x8) and 0 or CGameEffect.m_savingThrow, -- ignore save check if the save for half flag is set
							["saveMod"] = CGameEffect.m_saveMod,
							["m_flags"] = CGameEffect.m_flags,
							--
							["durationType"] = CGameEffect.m_durationType,
							["duration"] = CGameEffect.m_duration,
							--
							["spellLevel"] = CGameEffect.m_spellLevel,
							["m_projectileType"] = CGameEffect.m_projectileType,
							["m_school"] = CGameEffect.m_school,
							["m_secondaryType"] = CGameEffect.m_secondaryType,
							["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
							--
							["m_sourceType"] = CGameEffect.m_sourceType,
							["m_sourceFlags"] = CGameEffect.m_sourceFlags,
							["m_casterLevel"] = roll,
							["m_slotNum"] = CGameEffect.m_slotNum,
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
	--
	immunityToDamage:free()
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
