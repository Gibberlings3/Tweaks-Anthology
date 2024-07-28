-- cdtweaks, Metamagic: check if spellcasting is disabled (ignore op145 from armor in case of still spells) --

function GT_Metamagic_SpellcastingDisabled(CGameSprite, spellHeader, metamagicType)
	local toReturn = false
	local found = false
	--
	local spellcastingDisabled = function(effect)
		-- op144
		if effect.m_effectId == 144 and effect.m_dWFlags == 2 then -- location: cast spell button
			if metamagicType ~= 6 or effect.m_slotNum ~= 1 then
				found = true
				return true
			end
		end
		-- op145
		if effect.m_effectId == 145 and effect.m_dWFlags == 0 and spellHeader.itemType == 1 then
			if metamagicType ~= 6 or effect.m_slotNum ~= 1 then
				found = true
				return true
			end
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 1 and spellHeader.itemType == 2 then
			if metamagicType ~= 6 or effect.m_slotNum ~= 1 then
				found = true
				return true
			end
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 3 and EEex_IsBitUnset(spellHeader.itemFlags, 14) then
			if metamagicType ~= 6 or effect.m_slotNum ~= 1 then
				found = true
				return true
			end
		end
	end
	--
	if EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["POLYMORPHED"]) == 1 then
		toReturn = true
	else
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, spellcastingDisabled)
		if not found then
			EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, spellcastingDisabled)
		end
		--
		if found then
			toReturn = true
		end
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: Effects that don't go through the projectile, like Target = Self, won't mutated by the op408 --

function GT_Metamagic_SelfBuff(spellHeader, spellAbility, metamagicType)
	local toReturn = false
	--
	if (spellAbility.actionType == 5 or spellAbility.actionType == 7) and not (metamagicType == 1 or metamagicType == 5 or metamagicType == 6) then
		toReturn = true
		--
		local effectsCount = spellAbility.effectCount
		if effectsCount > 0 then
			local currentEffectAddress = EEex_UDToPtr(spellHeader) + spellHeader.effectsOffset + spellAbility.startingEffect * Item_effect_st.sizeof
			--
			for i = 1, effectsCount do
				local effect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
				if (effect.targetType == 2 or effect.targetType == 9) then
					toReturn = false
					break
				end
				currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
			end
		end
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: ``(Really)ForceSpell()`` ignores range and LoS, so we need to check them --

function GT_Metamagic_LOS(CGameSprite, CAIAction, spellAbility, metamagicType)
	local toReturn = false
	--
	if metamagicType == 1 or metamagicType == 5 then -- quicken spell / silent spell
		-- ``(Really)ForceSpell()`` ignores range and LoS, so we need to check them...
		if CAIAction.m_actionID == 192 or CAIAction.m_actionID == 477 then -- SpellPointNoDec() / EEex_SpellObjectOffsetNoDec()
			local numCreature = EEex_Area_GetAllOfTypeStringInRange(CGameSprite.m_pArea, CAIAction.m_dest.x, CAIAction.m_dest.y, "[ANYONE]", (spellAbility.range * 16 < CGameSprite:virtual_GetVisualRange()) and spellAbility.range or CGameSprite:virtual_GetVisualRange(), nil, nil, nil)
			for _, v in ipairs(numCreature) do
				if v.m_id == CGameSprite.m_id then
					toReturn = true
					break
				end
			end
		else -- ``SpellNoDec()``
			local targetSprite = EEex_GameObject_Get(CAIAction.m_acteeID.m_Instance)
			local numCreature = EEex_Area_GetAllOfTypeStringInRange(CGameSprite.m_pArea, targetSprite.m_pos.x, targetSprite.m_pos.y, "[ANYONE]", (spellAbility.range * 16 < CGameSprite:virtual_GetVisualRange()) and spellAbility.range or CGameSprite:virtual_GetVisualRange(), nil, nil, nil)
			for _, v in ipairs(numCreature) do
				if v.m_id == CGameSprite.m_id then
					toReturn = true
					break
				end
			end
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: ``(Really)ForceSpell()`` bypasses Invisibility and Sanctuary, so we need to check them --

function GT_Metamagic_InvisibilitySanctuary(CGameSprite, CAIAction, spellHeader, metamagicType)
	local toReturn = false
	--
	if metamagicType == 1 or metamagicType == 5 then -- quicken spell / silent spell
		-- ``(Really)ForceSpell()`` bypasses Invisibility and Sanctuary, so we need to check them...
		if CAIAction.m_actionID == 191 then -- SpellNoDec()
			local targetSprite = EEex_GameObject_Get(CAIAction.m_acteeID.m_Instance)
			--
			if targetSprite.m_id ~= CGameSprite.m_id then -- if the caster does not target self...
				local targetGeneralState = targetSprite.m_derivedStats.m_generalState
				local targetSanctuary = targetSprite.m_derivedStats.m_bSanctuary
				--
				local casterSeeInvisible = CGameSprite.m_derivedStats.m_bSeeInvisible
				--
				if casterSeeInvisible > 0 or (EEex_IsBitUnset(targetGeneralState, 0x4) and EEex_IsBitUnset(targetGeneralState, 22)) or EEex_IsBitSet(spellHeader.itemFlags, 24) then
					if targetSanctuary == 0 then
						toReturn = true
					end
				end
			else
				toReturn = true
			end
		else -- SpellPointNoDec() / EEex_SpellObjectOffsetNoDec()
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: ``(Really)ForceSpell()`` bypasses Silence, so we need to check it --

function GT_Metamagic_Silence(CGameSprite, spellHeader, metamagicType)
	local toReturn = false
	local casterGeneralState = CGameSprite.m_derivedStats.m_generalState
	--
	if metamagicType == 5 or EEex_IsBitSet(spellHeader.itemFlags, 25) or EEex_IsBitUnset(casterGeneralState, 12) then
		toReturn = true
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: Check if the caster has at least one spell memorized of level ``spellLevel`` + X, X depending on the selected metamagic feat --

function GT_Metamagic_ConsumeSlots(CGameSprite, spellHeader, metamagicType, spellResRef)
	local toReturn = false
	local spellLevelMemListArray
	--
	if spellHeader.itemType == 1 then -- Wizard
		spellLevelMemListArray = CGameSprite.m_memorizedSpellsMage
	elseif spellHeader.itemType == 2 then -- Priest
		spellLevelMemListArray = CGameSprite.m_memorizedSpellsPriest
	end
	--
	local metamagicReq = {4, 2, 1, 3, 1, 1} -- quicken (+4), empower (+2), extend (+1), maximize (+3), silent (+1), still (+1)
	--
	local alreadyDecreasedResrefs = {}
	local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel + metamagicReq[metamagicType] - 1) -- count starts from 0 (that is why ``-1``)
	--
	EEex_Utility_IterateCPtrList(memList, function(memInstance)
		local memInstanceResref = memInstance.m_spellId:get()
		if not alreadyDecreasedResrefs[memInstanceResref] then
			local memFlags = memInstance.m_flags
			if EEex_IsBitSet(memFlags, 0x0) then -- if memorized ...
				memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... then unmemorize
				toReturn = true
				alreadyDecreasedResrefs[memInstanceResref] = true
			end
		end
	end)
	-- SpellNoDec() does not decrement spell count, so we have to manually decrement it...
	if toReturn then
		local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- count starts from 0 (that is why ``-1``)
		EEex_Utility_IterateCPtrList(memList, function(memInstance)
			local memInstanceResref = memInstance.m_spellId:get()
			if memInstanceResref == spellResRef then
				local memFlags = memInstance.m_flags
				if EEex_IsBitSet(memFlags, 0x0) then -- if memorized ...
					memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... then unmemorize
					return true
				end
			end
		end)
	end
	--
	return toReturn
end

-- cdtweaks, Metamagic: Quicken Spell --

function GT_Metamagic_QuickenSpell(CGameSprite, CAIAction, casterLevel)
	if CAIAction.m_actionID == 191 then -- SpellNoDec()
		-- Morph ``SpellNoDec()`` into ``ReallyForceSpell()`` (so as to achieve immunity to spell disruption and a casting speed of 0)
		CAIAction.m_actionID = 181
		-- make sure caster level is preserved
		if CAIAction.m_string1.m_pchData:get() ~= "" then
			CAIAction.m_specificID = casterLevel
		end
	else
		-- Morph ``SpellPointNoDec()`` / ``EEex_SpellObjectOffsetNoDec()`` into ``ReallyForceSpellPoint()`` (so as to achieve immunity to spell disruption and a casting speed of 0)
		CAIAction.m_actionID = 337
		-- make sure caster level is preserved
		if CAIAction.m_string1.m_pchData:get() ~= "" then
			CAIAction.m_specificID = casterLevel
		end
	end
	-- ``ReallyForceSpell()`` does not set the aura, so we manually set it...
	CGameSprite.m_castCounter = 0
	CGameSprite.m_bInCasting = 1
end

-- cdtweaks, Metamagic: Silent Spell --

function GT_Metamagic_SilentSpell(CGameSprite, CAIAction, casterLevel)
	if CAIAction.m_actionID == 191 then -- SpellNoDec()
		-- Morph ``SpellNoDec()`` into ``ForceSpell()`` (so as to cast while silenced)
		CAIAction.m_actionID = 113
		-- make sure caster level is preserved
		if CAIAction.m_string1.m_pchData:get() ~= "" then
			CAIAction.m_specificID = casterLevel
		end
	else
		-- Morph ``SpellPointNoDec()`` / ``EEex_SpellObjectOffsetNoDec()`` into ``ForceSpellPoint()`` (so as to cast while silenced)
		CAIAction.m_actionID = 114
		-- make sure caster level is preserved
		if CAIAction.m_string1.m_pchData:get() ~= "" then
			CAIAction.m_specificID = casterLevel
		end
	end
	-- ``ForceSpell()`` does not set the aura, so we manually set it...
	CGameSprite.m_castCounter = 0
	CGameSprite.m_bInCasting = 1
end

-- cdtweaks, Metamagic (Silent Spell): ``ForceSpell()`` cannot be interrupted, so we have to manually do that

function GTSILSPL(CGameEffect, CGameSprite)
	if CGameSprite.m_curAction.m_actionID == 113 or CGameSprite.m_curAction.m_actionID == 114 then
		local found = false
		--
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 408 and effect.m_effectAmount == 5 then
				found = true
				return true
			end
		end)
		--
		if found then
			local roll = Infinity_RandomNumber(1, 20)
			--
			local constitution = CGameSprite.m_derivedStats.m_nCON + CGameSprite.m_bonusStats.m_nCON
			local conBonus = math.floor((constitution - 10) / 2)
			--
			local spellResRef = CGameSprite.m_curAction.m_string1.m_pchData:get()
			if spellResRef == "" then
				spellResRef = GT_Utility_DecodeSpell(CGameSprite.m_curAction.m_specificID)
			end
			--
			local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
			--
			local damageTaken = CGameSprite:getLocalInt("gtSilentSpellStartingHP") - CGameSprite.m_baseStats.m_hitPoints
			CGameSprite:setLocalInt("gtSilentSpellStartingHP", CGameSprite.m_baseStats.m_hitPoints) -- update tracking var
			--
			if roll + damageTaken > spellHeader.spellLevel + conBonus then
				CGameSprite.m_curAction.m_actionID = 0 -- nuke current action
				--
				CGameSprite:applyEffect({
					["effectID"] = 139, -- Display string
					["durationType"] = 1,
					["effectAmount"] = %strref_SpellDisrupted%,
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
				})
			end
		end
	end
end
