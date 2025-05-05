--[[
+--------------------------------------+
| cdtweaks, Revised Troll Regeneration |
+--------------------------------------+
--]]

-- +1d6 hp/round (regardless of haste/slow) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	--
	local aux = EEex_GetUDAux(sprite)
	--
	local found = false
	local regenerating = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 0 and effect.m_dWFlags == 0 and effect.m_effectAmount == 0 and effect.m_scriptName:get() == "gtTrollRegTimer" then -- dummy opcode that acts as a marker/timer
			found = true
		elseif effect.m_effectId == 403 and effect.m_res:get() == "GTTRLRG1" then
			regenerating = true
		end
	end)
	--
	if (spriteRaceStr == "TROLL" or spriteRaceStr == "SNOW_TROLL") and regenerating then
		if not found then
			-- skip if hit by fire/acid OR if in coma
			if not aux["gt_IsTrollRegHalted_Aux"] and not (EEex_IsBitSet(spriteGeneralState, 0x0) and sprite.m_derivedStats.m_nResistSlashing == 100) then
				sprite:applyEffect({
					["effectID"] = 17, -- cur hp bonus
					["numDice"] = 1,
					["diceSize"] = 6,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			-- set timer
			sprite:applyEffect({
				["effectID"] = 0, -- AC bonus
				["m_scriptName"] = "gtTrollRegTimer",
				["duration"] = 100,
				["durationType"] = 10, -- instant/limited (ticks)
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			--
			aux["gt_IsTrollRegHalted_Aux"] = nil
		end
	end
end)

-- op403 listener: any time they take fire or acid damage their regeneration is halted for one round (not cumulative) --

function GTTRLRG1(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	if CGameEffect.m_effectId == 0xC then -- damage
		if EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) or EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["ACID"]) then
			-- make sure it is *not* reflected
			if not GT_Sprite_HasBounceEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {402}, CGameEffect.m_flags) then
				CGameSprite:applyEffect({
					["effectID"] = 402, -- invoke lua
					["res"] = "GTTRLRG2", -- lua func
					--
					["durationType"] = CGameEffect.m_durationType,
					["duration"] = CGameEffect.m_duration,
					--
					["m_flags"] = CGameEffect.m_flags,
					["savingThrow"] = EEex_IsBitSet(CGameEffect.m_special, 0x8) and 0 or CGameEffect.m_savingThrow, -- ignore save check if the save for half flag is set
					["saveMod"] = CGameEffect.m_saveMod,
					--
					["spellLevel"] = CGameEffect.m_spellLevel,
					["m_projectileType"] = CGameEffect.m_projectileType,
					["m_school"] = CGameEffect.m_school,
					["m_secondaryType"] = CGameEffect.m_secondaryType,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					--
					["m_sourceType"] = CGameEffect.m_sourceType,
					["m_sourceFlags"] = CGameEffect.m_sourceFlags,
					["m_slotNum"] = CGameEffect.m_slotNum,
					["m_casterLevel"] = CGameEffect.m_casterLevel,
					--
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
end

-- op402 listener --

function GTTRLRG2(CGameEffect, CGameSprite)
	local aux = EEex_GetUDAux(CGameSprite)
	--
	aux["gt_IsTrollRegHalted_Aux"] = true
	--
	CGameEffect.m_done = true
end

