-- get (true) spell level (f.i., Secret Word is actually a level 5 spell, not 4) --

function GT_AI_GetTrueSpellLevel(pHeader, pAbility, ext)
	local toReturn = string.upper(ext) == "SPL" and pHeader.spellLevel or 0
	--
	if pAbility.effectCount > 0 then
		local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
		--
		for idx = 1, pAbility.effectCount do
			local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
			--
			if pEffect.spellLevel > 0 then
				toReturn = pEffect.spellLevel
				break
			end
			--
			currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
		end
	end
	--
	return toReturn
end

