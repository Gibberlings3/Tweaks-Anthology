--[[
+---------------------------------------------------------------------------+
| cdtweaks, extra dispel feedback                                           |
+---------------------------------------------------------------------------+
| Clearly display the magical effects dispelled by op58, 220, 221, 229, 230 |
+---------------------------------------------------------------------------+
--]]

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
						for k, v in pairs(GT_Subspell_LookUpTable) do
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

