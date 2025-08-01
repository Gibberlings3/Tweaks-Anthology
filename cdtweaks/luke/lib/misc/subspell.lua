--[[
+-------------------------------------------------+
| List all resources and their subspells (if any) |
+-------------------------------------------------+
--]]

-- yes, all of this is *ugly* (and relies upon subspells being globally unique), but unfortunately there isn't currently a reliable way to track subspells... --
-- the important thing is that it *should* take (very) little processing time (less than 200 ms on an unmodded iwdee install...) --

-- EFF V2.0 --

local function EFF_V20(parentFile, CGameEffectBase)
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
		subSplHeader, subSplResRef = EFF_V20(parentFile, EEex_Resource_Demand(CGameEffectBase.m_res:get(), "eff")) -- recursive call
	end
	--
	return subSplHeader, subSplResRef
end

-- SPL / ITM effects --

local function EFF_V10(parentFile, pHeader, ext, srcResRef)
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
				subSplHeader, subSplResRef = EFF_V20(parentFile, EEex_Resource_Demand(pEffect.res:get(), "eff"))
			end
			--
			if subSplHeader and subSplResRef then -- sanity check
				if Infinity_FetchString(subSplHeader.genericName) == "" then
					if not GT_Subspell_LookUpTable[parentFile] or not GT_Utility_ArrayContains(GT_Subspell_LookUpTable[parentFile], subSplResRef) then
						-- initialize
						if not GT_Subspell_LookUpTable[parentFile] then
							GT_Subspell_LookUpTable[parentFile] = {}
						end
						--
						table.insert(GT_Subspell_LookUpTable[parentFile], subSplResRef)
						-- check for (sub)subspells
						EFF_V10(parentFile, subSplHeader, "spl", subSplResRef) -- recursive call
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
	GT_Subspell_LookUpTable = {}
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
							EFF_V10(string.upper(resref) .. "." .. string.upper(ext), pHeader, ext, string.upper(resref))
						end
					end
				end
			end
		end
	end
	--
	--print("***END***" .. " -> " .. os.clock() .. "\n\n\n\n\n") -- for testing purposes only (requires LuaJIT)
	--[[
	for k, v in pairs(GT_Subspell_LookUpTable) do
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

