--[[
+--------------------------------------+
| cdtweaks, Revised Troll Regeneration |
+--------------------------------------+
--]]

-- flag regenerating trolls as such --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	--
	local func
	func = function(effect)
		local m_sourceType = effect.m_sourceType
		local m_sourceRes = effect.m_sourceRes:get()
		local tocheck = false
		--
		if m_sourceType == 2 then
			local pHeader = EEex_Resource_Demand(m_sourceRes, "itm")
			--
			if EEex_IsBitUnset(pHeader.itemFlags, 0x2) then
				tocheck = true
			end
		else
			if m_sourceRes == "" then
				tocheck = true
			end
		end
		--
		if tocheck then
			if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
				local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
				--
				if CGameEffectBase then -- sanity check
					local result = func(CGameEffectBase)
					if result then
						return true
					end
				end
			elseif effect.m_effectId == 98 then -- Regeneration
				return true
			end
		end
	end
	--
	if (spriteRaceStr == "TROLL" or spriteRaceStr == "SNOW_TROLL") then
		local effectList = {sprite.m_timedEffectList, sprite.m_equipedEffectList}
		--
		local found = false
		for _, list in ipairs(effectList) do
			EEex_Utility_IterateCPtrList(list, function(effect)
				if func(effect) then
					effect.m_sourceRes:set("GTTRLREG")
					found = true
				end
			end)
		end
		--
		if found then
			local effectCodes = {
				{["op"] = 321, ["res"] = "GTTRLREG"}, -- remove effects by resource
				{["op"] = 321, ["res"] = "GTTRLRG1"}, -- remove effects by resource
				{["op"] = 142, ["p2"] = 56}, -- icon: regenerating
				{["op"] = 403, ["res"] = "GTTRLRG1"}, -- screen effects
			}
			--
			for _, attributes in ipairs(effectCodes) do
				sprite:applyEffect({
					["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
					["dwFlags"] = attributes["p2"] or 0,
					["res"] = attributes["res"] or "",
					["durationType"] = 9,
					["m_sourceRes"] = "GTTRLRG1",
					["noSave"] = true,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- +1d6 hp/round (regardless of haste/slow) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	--
	local aux = EEex_GetUDAux(sprite)
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerRunning = false
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtTrollRegTimer" then -- dummy opcode that acts as a marker/timer
			timerRunning = true
		elseif effect.m_effectId == 403 and effect.m_res:get() == "GTTRLRG1" then
			found = true
		end
	end)
	--
	if found then
		if not timerRunning then
			-- skip if hit by fire/acid OR if in coma
			if not aux["gt_PnP_IsTrollRegHalted"] and not (EEex_IsBitSet(spriteGeneralState, 0x0) and sprite.m_derivedStats.m_nResistSlashing == 100) then
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
				["effectID"] = 401, -- set extended stat
				["special"] = stats["GT_DUMMY_STAT"],
				["m_scriptName"] = "gtTrollRegTimer",
				["duration"] = 90, -- 90 ticks ~ 1 round
				["durationType"] = 10, -- instant/limited (ticks)
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			--
			aux["gt_PnP_IsTrollRegHalted"] = nil
		end
	end
end)

-- op403 listener: any time they take fire or acid damage their regeneration is halted for one round (not cumulative) --

function GTTRLRG1(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local fields
	local found = false
	local forceApplyViaOp177 = false
	--
	if CGameEffect.m_effectId == 0xC then -- damage
		if EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) or EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["ACID"]) then
			found = true
			fields = GT_Utility_GetEffectFields(CGameEffect)
		end
	elseif CGameEffect.m_effectId == 0xB1 and CGameEffect.m_effectAmount4 ~= 0 then -- https://github.com/Gibberlings3/iesdp/pull/193
		if GT_Sprite_CheckIDS(CGameSprite, CGameEffect.m_effectAmount, CGameEffect.m_dWFlags) then
			local CGameEffectBase = EEex_Resource_Demand(CGameEffect.m_res:get(), "eff")
			-- sanity check
			if CGameEffectBase then
				if CGameEffectBase.m_effectId == 0xC then
					if EEex_IsMaskSet(CGameEffectBase.m_dWFlags, dmgtype["FIRE"]) or EEex_IsMaskSet(CGameEffectBase.m_dWFlags, dmgtype["ACID"]) then
						found = true
						forceApplyViaOp177 = true
						fields = GT_Utility_GetEffectFields(CGameEffectBase)
					end
				end
			end
		end
	end
	--
	if found then
		-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
		-- opcodes applied here *should* use the same roll for saves and mr checks...
		-- make sure it is *not* reflected/deflected/trapped
		if not GT_Sprite_HasBounceEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {402, 12}, fields["flags"]) or forceApplyViaOp177 then
			if not GT_Sprite_HasImmunityEffects(CGameSprite, fields["spellLevel"], fields["projectileType"], fields["school"], fields["secondaryType"], fields["sourceRes"], {402, 12}, fields["flags"], fields["savingThrow"], 0x0) or forceApplyViaOp177 then
				if not GT_Sprite_HasTrapEffect(CGameSprite, fields["spellLevel"], fields["secondaryType"], fields["flags"]) or forceApplyViaOp177 then
					--
					CGameSprite:applyEffect({
						["effectID"] = 402, -- invoke lua
						["res"] = "GTTRLRG2", -- lua func
						--
						["durationType"] = CGameEffect.m_durationType,
						["duration"] = CGameEffect.m_duration,
						--
						["m_flags"] = fields["flags"],
						["savingThrow"] = EEex_IsBitSet(fields["special"], 0x8) and 0 or fields["savingThrow"], -- ignore save check if the save for half flag is set
						["saveMod"] = fields["saveMod"],
						--
						["spellLevel"] = fields["spellLevel"],
						["m_projectileType"] = fields["projectileType"],
						["m_school"] = fields["school"],
						["m_secondaryType"] = fields["secondaryType"],
						["m_sourceRes"] = fields["sourceRes"],
						--
						["m_sourceType"] = fields["sourceType"],
						["m_sourceFlags"] = fields["sourceFlags"],
						["m_casterLevel"] = fields["casterLevel"],
						["m_slotNum"] = fields["slotNum"],
						--
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			end
		end
	end
end

-- op402 listener --

function GTTRLRG2(CGameEffect, CGameSprite)
	local aux = EEex_GetUDAux(CGameSprite)
	--
	aux["gt_PnP_IsTrollRegHalted"] = true
	--
	CGameEffect.m_done = true
end

