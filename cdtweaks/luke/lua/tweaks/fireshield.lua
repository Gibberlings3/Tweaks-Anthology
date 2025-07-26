--[[
+-------------------------------------------------------------------------------------------+
| cdtweaks, More Sensible Fireshield                                                        |
+-------------------------------------------------------------------------------------------+
| Fixes two things:                                                                         |
| 1. Fireshield-like spells will no longer bounce back and forth ad infinitum               |
| 2. Only true melee attacks will trigger these spells (no longer ranged attacks or poison) |
+-------------------------------------------------------------------------------------------+
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
			if effect.m_effectAmount == 1 and effect.m_dWFlags == 0 then -- Target: LastHitter / Condition: HitBy([ANYONE])
				effect.m_effectId = 401 -- Set extended stat
				effect.m_effectAmount = 1
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
							if pEffect.effectAmount == 1 and pEffect.dwFlags == 0 then -- Target: LastHitter / Condition: HitBy([ANYONE])
								pEffect.effectID = 401 -- Set extended stat
								pEffect.effectAmount = 1
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
	local fireShield = {}
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
			if effect.m_effectAmount == 1 and effect.m_dWFlags == 0 then -- Target: LastHitter / Condition: HitBy([ANYONE])
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
			table.insert(fireShield, {m_res, m_res2, m_res3, GT_Utility_GetEffectFields(effect)})
			-- Absolute timing mode, instantly marked for removal
			effect.m_durationType = 0x1000
			effect.m_duration = 0
		end
	end)
	--
	if next(fireShield) then
		-- force the engine to reevaluate the effect list after the change
		sprite.m_newEffect = true
		-- apply op401
		for _, v in ipairs(fireShield) do
			sprite:applyEffect({
				["effectID"] = 401, -- set extended stat
				["dwFlags"] = 1, -- mode: set
				["effectAmount"] = 1,
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

EEex_Sprite_AddBlockWeaponHitListener(function(args)
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local weapon = args.weapon -- CItem
	local weaponAbility = args.weaponAbility -- Item_ability_st
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	-- check for Fireshield-like spells
	local effectList = {targetSprite.m_equipedEffectList, targetSprite.m_timedEffectList} -- CGameEffectList
	local fireShield = {}
	--
	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				return func(CGameEffectBase)
			end
		elseif effect.m_effectId == 401 and effect.m_dWFlags == 1 and effect.m_effectAmount == 1 and effect.m_special == stats["GT_FAKE_CONTINGENCY"] then
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
				table.insert(fireShield, {m_res, m_res2, m_res3})
			end
		end)
	end
	--
	if weaponAbility.type == 1 and weaponAbility.range <= 2 then -- melee weapons only
		-- apply retaliation damage
		for _, v in ipairs(fireShield) do
			for _, res in ipairs(v) do
				if res ~= "" then
					attackingSprite:applyEffect({
						["effectID"] = 146, -- Cast spl
						["dwFlags"] = 1, -- mode: cast instantly / ignore level
						["res"] = res,
						["sourceID"] = targetSprite.m_id,
						["sourceTarget"] = attackingSprite.m_id,
					})
				end
			end
		end
	end
end)
