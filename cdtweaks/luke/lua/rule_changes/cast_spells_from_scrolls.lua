--[[
+------------------------------------------------------------------------------+
| cdtweaks, Make sure casting spells from scrolls can be interrupted by damage |
+------------------------------------------------------------------------------+
--]]

EEex_GameState_AddInitializedListener(function()
	local itmFileList = Infinity_GetFilesOfType("itm")
	-- for some unknown reason, we need two nested loops in order to get the resref...
	for _, temp in ipairs(itmFileList) do
		for _, res in pairs(temp) do
			local pHeader = EEex_Resource_Demand(res, "itm") -- Item_Header_st
			-- sanity check
			if pHeader then
				-- only care for droppable and displayable items
				if EEex_IsBitSet(pHeader.itemFlags, 0x2) and EEex_IsBitSet(pHeader.itemFlags, 0x3) then
					if pHeader.itemType == 0xB then -- scrolls
						local abilitiesCount = pHeader.abilityCount
						if abilitiesCount > 0 then
							local currentAbilityAddress = EEex_UDToPtr(pHeader) + pHeader.abilityOffset
							--
							for i = 1, abilitiesCount do
								local pAbility = EEex_PtrToUD(currentAbilityAddress, "Item_ability_st") -- Item_ability_st
								if pAbility then -- sanity check
									local effectsCount = pAbility.effectCount
									if effectsCount > 0 then
										local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
										--
										for j = 1, effectsCount do
											local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st") -- Item_effect_st
											if pEffect then -- sanity check
												if (pEffect.effectID == 0x92 or pEffect.effectID == 0x94) and pEffect.dwFlags == 0x0 then -- op146/148 (normal mode)
													-- adjust the special field
													pEffect.special = EEex_SetBit(pEffect.special, 0x0) -- see "https://github.com/Bubb13/EEex/pull/105"
												end
											end
											--
											currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
										end
									end
								end
								--
								currentAbilityAddress = currentAbilityAddress + Item_ability_st.sizeof
							end
						end
					end
				end
			end
		end
	end
end)

