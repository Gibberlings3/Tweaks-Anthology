--[[
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| cdtweaks, Blade Barrier vs. Time Stop                                                                                                                   |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| As currently implemented, Blade Barrier and similar spells interact very oddly with time stop effects.                                                  |
| Freeze two characters in melee range, one with a Blade Barrier (or Globe of Blades, or Circle of Bones, or any mod spell that uses the same mechanics), |
| and the spell triggers several times to no immediate effect...                                                                                          |
| until stopped time wears off. Then all of those suspended triggers hit at once, for a potential massive burst of damage.                                |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

-- equipped effects (run me as soon as the game launches) --

EEex_GameState_AddInitializedListener(function()
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				func(CGameEffectBase)
			end
		elseif effect.m_effectId == 232 then -- Cast spell on condition
			if effect.m_effectAmount == 0 and effect.m_dWFlags == 8 then -- Target: Myself / Condition: PersonalSpaceDistance([ANYONE],4)
				effect.m_effectId = 401 -- Set extended stat
				effect.m_effectAmount = 2
				effect.m_dWFlags = 1 -- mode: set
				effect.m_special = stats["GT_FAKE_CONTINGENCY"]
			end
		end
	end
	--
	local itmFileList = Infinity_GetFilesOfType("itm")
	-- for some unknown reason, we need two nested loops in order to get the resref...
	for _, temp in ipairs(itmFileList) do
		for _, resref in pairs(temp) do
			local pHeader = EEex_Resource_Demand(resref, "itm")
			--
			if pHeader then
				if pHeader.equipedEffectCount > 0 then
					local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pHeader.equipedStartingEffect * Item_effect_st.sizeof
					--
					for i = 1, pHeader.equipedEffectCount do
						local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
						--
						if pEffect.effectID == 232 then -- Cast spell on condition
							if pEffect.effectAmount == 0 and pEffect.dwFlags == 8 then -- Target: Myself / Condition: PersonalSpaceDistance([ANYONE],4)
								pEffect.effectID = 401 -- Set extended stat
								pEffect.effectAmount = 2
								pEffect.dwFlags = 1 -- mode: set
								pEffect.special = stats["GT_FAKE_CONTINGENCY"]
							end
						elseif pEffect.effectID == 177 or pEffect.effectID == 283 then -- Use EFF file
							local CGameEffectBase = EEex_Resource_Demand(pEffect.res:get(), "eff")
							--
							if CGameEffectBase then
								func(CGameEffectBase)
							end
						end
						--
						currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
					end
				end
			end
		end
	end
end)

-- timed/limited effects --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local bladeBarrier = {}
	--
	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				return func(CGameEffectBase)
			end
		elseif effect.m_effectId == 232 then -- Cast spell on condition
			if effect.m_effectAmount == 0 and effect.m_dWFlags == 8 then -- Target: Myself / Condition: PersonalSpaceDistance([ANYONE],4)
				return effect.m_res:get(), effect.m_res2:get(), effect.m_res3:get()
			end
		end
		--
		return nil, nil, nil
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		local m_res, m_res2, m_res3 = func(effect)
		--
		if m_res or m_res2 or m_res3 then
			table.insert(bladeBarrier, {m_res, m_res2, m_res3, GT_Utility_GetEffectFields(effect)})
			-- Absolute timing mode, instantly marked for removal
			effect.m_durationType = 0x1000
			effect.m_duration = 0
		end
	end)
	--
	if next(bladeBarrier) then
		-- force the engine to reevaluate the effect list after the change
		sprite.m_newEffect = true
		-- apply op401
		for _, v in ipairs(bladeBarrier) do
			sprite:applyEffect({
				["effectID"] = 401, -- set extended stat
				["dwFlags"] = 1, -- mode: set
				["effectAmount"] = 2,
				["special"] = stats["GT_FAKE_CONTINGENCY"],
				--
				["res"] = v[1] or "",
				["m_res2"] = v[2] or "",
				["m_res3"] = v[3] or "",
				--
				["noSave"] = true,
				--
				["duration"] = v[4]["duration"],
				["durationType"] = v[4]["timing"],
				--
				["numDice"] = v[4]["numDice"],
				["diceSize"] = v[4]["diceSize"],
				--
				["spellLevel"] = v[4]["spellLevel"],
				["m_projectileType"] = v[4]["projectileType"],
				["m_school"] = v[4]["school"],
				["m_secondaryType"] = v[4]["secondaryType"],
				["m_sourceRes"] = v[4]["sourceRes"],
				--
				["m_sourceType"] = v[4]["sourceType"],
				["m_sourceFlags"] = v[4]["sourceFlags"],
				["m_scriptName"] = v[4]["scriptName"],
				["m_slotNum"] = v[4]["slotNum"],
				["m_casterLevel"] = v[4]["casterLevel"],
				["m_flags"] = v[4]["flags"],
				--
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- main --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local m_nTimeStopCaster = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nTimeStopCaster
	--local isImmuneToTimeStop = m_nTimeStopCaster == sprite.m_id or sprite.m_derivedStats.m_bImmuneToTimeStop > 0 -- N.B.: the caster is always immune to its own time stop
	-- check for Blade Barrier &c.
	local effectList = {sprite.m_equipedEffectList, sprite.m_timedEffectList} -- CGameEffectList
	local bladeBarrier = {}
	--
	local timerRunning = false
	--
	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				return func(CGameEffectBase)
			end
		elseif effect.m_effectId == 401 and effect.m_dWFlags == 1 and effect.m_effectAmount == 2 and effect.m_special == stats["GT_FAKE_CONTINGENCY"] then
			return effect.m_res:get(), effect.m_res2:get(), effect.m_res3:get()
		end
		--
		return nil, nil, nil
	end
	--
	for _, list in ipairs(effectList) do
		EEex_Utility_IterateCPtrList(list, function(effect)
			local m_res, m_res2, m_res3 = func(effect)
			--
			if m_res or m_res2 or m_res3 then
				table.insert(bladeBarrier, {m_res, m_res2, m_res3})
			elseif effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtBladeBarrierTimer" then -- dummy opcode that acts as a marker/timer
				timerRunning = true
			end
		end)
	end
	--
	if next(bladeBarrier) then
		if not timerRunning then
			if m_nTimeStopCaster == -1 then
				-- cast subspell(s)
				for _, v in ipairs(bladeBarrier) do
					for _, res in ipairs(v) do
						if res ~= "" then
							sprite:applyEffect({
								["effectID"] = 146, -- Cast spl
								["dwFlags"] = 1, -- mode: cast instantly / ignore level
								["res"] = res,
								["sourceID"] = sprite.m_id,
								["sourceTarget"] = sprite.m_id,
							})
						end
					end
				end
				-- set timer
				sprite:applyEffect({
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_DUMMY_STAT"],
					["m_scriptName"] = "gtBladeBarrierTimer",
					["duration"] = 100,
					["durationType"] = 10, -- instant/limited (ticks)
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)
