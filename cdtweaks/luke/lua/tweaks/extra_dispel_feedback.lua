--[[
+---------------------------------------------------------------------------+
| cdtweaks, extra dispel feedback                                           |
+---------------------------------------------------------------------------+
| Clearly display the magical effects dispelled by op58, 220, 221, 229, 230 |
+---------------------------------------------------------------------------+
--]]

-- yes, all of this is *ugly* (and relies upon subspells being globally unique), but unfortunately there isn't currently a reliable way to track subspells... --
-- the important thing is that it *should* take (very) little processing time (less than 200 ms on an unmodded iwdee install...) --

-- EFF V2.0 --

function GT_ExtraDispelFeedback_Subspell_EFF(parentFile, CGameEffectBase)
	-- initialize
	local subSplHeader
	local subSplResRef
	--
	if CGameEffectBase.m_effectId == 146 or CGameEffectBase.m_effectId == 148 or CGameEffectBase.m_effectId == 326 then -- Cast spell, cast spell at point, apply effects list
		subSplResRef = string.upper(CGameEffectBase.m_res:get())
		subSplHeader = EEex_Resource_Demand(subSplResRef, "spl")
	elseif CGameEffectBase.m_effectId == 333 or (CGameEffectBase.m_effectId == 78 and (CGameEffectBase.m_dWFlags == 11 or CGameEffectBase.m_dWFlags == 12)) then -- Static charge / Disease (mold touch)
		subSplResRef = string.upper(CGameEffectBase.m_res:get())
		--
		if subSplResRef == "" then
			if string.len(CGameEffectBase.m_sourceRes:get()) <= 7 then
				subSplResRef = CGameEffectBase.m_sourceRes:get() .. "B"
			else
				subSplResRef = CGameEffectBase.m_sourceRes:get()
			end
		end
		--
		subSplHeader = EEex_Resource_Demand(subSplResRef, "spl")
	elseif CGameEffectBase.m_effectId == 177 or CGameEffectBase.m_effectId == 283 then -- Use EFF file
		subSplHeader, subSplResRef = GT_ExtraDispelFeedback_Subspell_EFF(parentFile, EEex_Resource_Demand(CGameEffectBase.m_res:get(), "eff")) -- recursive call
	end
	--
	return subSplHeader, subSplResRef
end

-- SPL / ITM effects --

function GT_ExtraDispelFeedback_Subspell(parentFile, pHeader, ext, srcResRef)
	local currentAbilityAddress = EEex_UDToPtr(pHeader) + pHeader.abilityOffset
	--
	for i = 1, pHeader.abilityCount do
		local pAbility = EEex_PtrToUD(currentAbilityAddress, ext == "spl" and "Spell_ability_st" or "Item_ability_st")
		--
		local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
		--
		for j = 1, pAbility.effectCount do
			-- initialize
			local subSplHeader
			local subSplResRef
			--
			local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
			--
			if pEffect.effectID == 146 or pEffect.effectID == 148 or pEffect.effectID == 326 then -- Cast spell, cast spell at point, apply effects list
				subSplResRef = string.upper(pEffect.res:get())
				subSplHeader = EEex_Resource_Demand(subSplResRef, "spl")
			elseif pEffect.effectID == 333 or (pEffect.effectID == 78 and (pEffect.dwFlags == 11 or pEffect.dwFlags == 12)) then -- Static charge / Disease (mold touch)
				subSplResRef = string.upper(pEffect.res:get())
				--
				if subSplResRef == "" then
					if #srcResRef <= 7 then
						subSplResRef = srcResRef .. "B"
					else
						subSplResRef = srcResRef
					end
				end
				--
				subSplHeader = EEex_Resource_Demand(subSplResRef, "spl")
			elseif pEffect.effectID == 177 or pEffect.effectID == 283 then -- Use EFF file
				subSplHeader, subSplResRef = GT_ExtraDispelFeedback_Subspell_EFF(parentFile, EEex_Resource_Demand(pEffect.res:get(), "eff"))
			end
			--
			if subSplHeader and subSplResRef then -- sanity check
				if Infinity_FetchString(subSplHeader.genericName) == "" then
					if not GT_ExtraDispelFeedback_LookUpTable[parentFile] or not GT_Utility_ArrayContains(GT_ExtraDispelFeedback_LookUpTable[parentFile], subSplResRef) then
						-- initialize
						if not GT_ExtraDispelFeedback_LookUpTable[parentFile] then
							GT_ExtraDispelFeedback_LookUpTable[parentFile] = {}
						end
						--
						table.insert(GT_ExtraDispelFeedback_LookUpTable[parentFile], subSplResRef)
						-- check for (sub)subspells
						GT_ExtraDispelFeedback_Subspell(parentFile, subSplHeader, "spl", subSplResRef) -- recursive call
					end
				end
			end
			--
			currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
		end
		--
		currentAbilityAddress = currentAbilityAddress + (ext == "spl" and Spell_ability_st.sizeof or Item_ability_st.sizeof)
	end
end

-- run me as soon as the game launches --

EEex_GameState_AddInitializedListener(function()
	--print("***START***" .. " -> " .. os.clock()) -- for testing purposes only (requires LuaJIT)
	--
	local fileExt = {"itm", "spl"}
	GT_ExtraDispelFeedback_LookUpTable = {}
	--
	for _, ext in ipairs(fileExt) do
		local fileList = Infinity_GetFilesOfType(ext)
		-- for some unknown reason, we need two nested loops in order to get the resref...
		for _, temp in ipairs(fileList) do
			for _, resref in pairs(temp) do
				local pHeader = EEex_Resource_Demand(resref, ext)
				--
				if pHeader then
					if ext == "itm" or Infinity_FetchString(pHeader.genericName) ~= "" then -- skip subspells...
						if ext == "spl" or (EEex_IsBitSet(pHeader.itemFlags, 0x2) and EEex_IsBitSet(pHeader.itemFlags, 0x3)) then -- if it's a spell or an item flagged as DROPPABLE and DISPLAYABLE...
							-- check for subspells
							GT_ExtraDispelFeedback_Subspell(string.upper(resref) .. "." .. string.upper(ext), pHeader, ext, string.upper(resref))
						end
					end
				end
			end
		end
	end
	--
	--print("***END***" .. " -> " .. os.clock() .. "\n\n\n\n\n") -- for testing purposes only (requires LuaJIT)
	--[[
	for k, v in pairs(GT_ExtraDispelFeedback_LookUpTable) do
		local str = ""
		--
		for _, res in ipairs(v) do
			str = str .. res .. ", "
		end
		--
		print(k .. " => " .. str)
	end
	--]]
end)

-- apply condition (listener) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual listener
	local apply = function()
		-- Mark the creature as 'listener applied'
		sprite:setLocalInt("gtExtraDispelFeedback", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTDSPL01",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTDSPL02", -- lua function
			["m_sourceRes"] = "GTDSPL01",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check if there are dispellable effects (guess we can safely ignore equipped effects...)
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_school > 0 or effect.m_secondaryType > 0 or EEex_IsBitSet(effect.m_flags, 0x0) then
			found = true
			return true
		end
	end)
	--
	local applyListener = found
	--
	if sprite:getLocalInt("gtExtraDispelFeedback") == 0 then
		if applyListener then
			apply()
		end
	else
		if applyListener then
			-- do nothing
		else
			-- Mark the creature as 'listener removed'
			sprite:setLocalInt("gtExtraDispelFeedback", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTDSPL01",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op403 listener (save all relevant effects just before op58/220/221/229/230 lands) --

function GTDSPL02(op403CGameEffect, CGameEffect, CGameSprite)
	local aux = EEex_GetUDAux(CGameSprite)
	--
	if CGameEffect.m_effectId == 58 or CGameEffect.m_effectId == 220 or CGameEffect.m_effectId == 229 or CGameEffect.m_effectId == 221 or CGameEffect.m_effectId == 230 then -- Dispel effects, Remove spell school protections / Remove protection by school, Remove spell type protections / Remove protection by type
		-- initialize
		if not aux["gt_ExtraDispelFeedback_EffectsBefore"] then
			aux["gt_ExtraDispelFeedback_EffectsBefore"] = {}
		end
		-- Save dispellable effects (guess we can safely ignore equipped effects...)
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
			if effect.m_school > 0 or effect.m_secondaryType > 0 or EEex_IsBitSet(effect.m_flags, 0x0) then -- if dispellable...
				local ext
				--
				if effect.m_sourceType == 1 then
					ext = "SPL"
				elseif effect.m_sourceType == 2 or effect.m_sourceType == 0 then
					ext = "ITM"
				end
				--
				if ext then -- sanity check
					aux["gt_ExtraDispelFeedback_EffectsBefore"][effect.m_sourceRes:get() .. "." .. ext] = true
				end
			end
		end)
	end
end

-- compare effect list before and after op58/220/221/229/230 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local aux = EEex_GetUDAux(sprite)
	--
	if aux["gt_ExtraDispelFeedback_EffectsBefore"] then
		-- initialize
		aux["gt_ExtraDispelFeedback_EffectsAfter"] = {}
		-- Save dispellable effects (guess we can safely ignore equipped effects...)
		EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
			if effect.m_school > 0 or effect.m_secondaryType > 0 or EEex_IsBitSet(effect.m_flags, 0x0) then -- if dispellable...
				local ext
				--
				if effect.m_sourceType == 1 then
					ext = "SPL"
				elseif effect.m_sourceType == 2 or effect.m_sourceType == 0 then
					ext = "ITM"
				end
				--
				if ext then -- sanity check
					aux["gt_ExtraDispelFeedback_EffectsAfter"][effect.m_sourceRes:get() .. "." .. ext] = true
				end
			end
		end)
		-- initialize
		local todisplay = {}
		local feedbackString = Infinity_FetchString(%feedback_strref%) .. " : "
		-- perform comparison
		for before in pairs(aux["gt_ExtraDispelFeedback_EffectsBefore"]) do
			local found = false
			--
			for after in pairs(aux["gt_ExtraDispelFeedback_EffectsAfter"]) do
				if before == after then
					found = true
					break
				end
			end
			--
			if not found then
				local pHeader = EEex_Resource_Demand(string.sub(before, 1, -5), string.sub(before, -3))
				local file = before
				--
				if pHeader then -- sanity check
					if Infinity_FetchString(pHeader.genericName) == "" then
						for k, v in pairs(GT_ExtraDispelFeedback_LookUpTable) do
							if GT_Utility_ArrayContains(v, string.sub(before, 1, -5)) then
								file = k
								break
							end
						end
					end
				end
				--
				todisplay[file] = true
			end
		end
		--
		for key in pairs(todisplay) do
			local pHeader = EEex_Resource_Demand(string.sub(key, 1, -5), string.sub(key, -3))
			--
			if string.sub(key, -3) == "SPL" then
				feedbackString = feedbackString .. Infinity_FetchString(pHeader.genericName) .. ", "
			else
				if Infinity_FetchString(pHeader.identifiedName) ~= "" then
					feedbackString = feedbackString .. Infinity_FetchString(pHeader.identifiedName) .. ", "
				else
					feedbackString = feedbackString .. Infinity_FetchString(pHeader.genericName) .. ", "
				end
			end
		end
		-- cleanup
		feedbackString = feedbackString:gsub(", $", "")
		-- actual display
		GT_Sprite_DisplayMessage(sprite, feedbackString, 0x108544) -- Dark Sea Green
		--
		aux["gt_ExtraDispelFeedback_EffectsAfter"] = nil
		aux["gt_ExtraDispelFeedback_EffectsBefore"] = nil
	end
end)

