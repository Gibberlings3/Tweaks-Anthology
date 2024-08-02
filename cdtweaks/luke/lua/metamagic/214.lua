-- cdtweaks, metamagic feat for spellcasters: display a list of spells that can be modified --

function GTSPMENU(CGameEffect, CGameSprite)
	if CGameSprite:getLocalInt("cdtweaksSpontaneousCast") > 0 then
		CGameSprite:setLocalInt("cdtweaksSpontaneousCast", 0) -- cannot be used in conjunction with the Cleric Spontaneous Cast feat
	end
	--
	local metamagicReq = {4, 2, 1, 3, 1, 1} -- quicken (+4), empower (+2), extend (+1), maximize (+3), silent (+1), still (+1)
	local metamagicType = EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])
	--
	return EEex_Actionbar_GetOp214ButtonDataItr(EEex_Utility_SelectItr(3, EEex_Utility_FilterItr(
		EEex_Utility_ChainItrs(
			CGameSprite:getKnownPriestSpellsWithAbilityIterator(1, 7 - metamagicReq[metamagicType]),
			CGameSprite:getKnownMageSpellsWithAbilityIterator(1, 9 - metamagicReq[metamagicType])
		),
		function(spellLevel, knownSpellIndex, spellResRef, spellHeader, spellAbility)
			--unless I'm missing something, op145 (Disable Spellcasting) / op38 (Silence) make ``HaveSpell()`` return ``false``...?
			--local isSpellMemorized = EEex_Trigger_ParseConditionalString(string.format('HaveSpellRES("%s")', spellResRef))
			local isSpellMemorized = false
			local spellLevelMemListArray
			--
			if spellHeader.itemType == 1 then -- Wizard
				spellLevelMemListArray = CGameSprite.m_memorizedSpellsMage
			elseif spellHeader.itemType == 2 then -- Priest
				spellLevelMemListArray = CGameSprite.m_memorizedSpellsPriest
			end
			--
			local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- count starts from 0 (that is why ``-1``)
			EEex_Utility_IterateCPtrList(memList, function(memInstance)
				local memInstanceResref = memInstance.m_spellId:get()
				if memInstanceResref == spellResRef then
					local memFlags = memInstance.m_flags
					if EEex_IsBitSet(memFlags, 0x0) then -- make sure it is memorized
						isSpellMemorized = true
						return true
					end
				end
			end)
			--
			if isSpellMemorized then
				-- effects that don't go through the projectile, like Target = Self, won't mutated by the op408
				if not GT_Metamagic_SelfBuff(spellHeader, spellAbility, metamagicType) then
					return true
				end
			end
		end
	)))
end
