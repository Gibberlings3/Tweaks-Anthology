-- cdtweaks, metamagic feat for spellcasters: display a list of spells that can be modified --

function GTSPMENU(CGameEffect, CGameSprite)
	if CGameSprite:getLocalInt("cdtweaksSpontaneousCast") > 0 then
		CGameSprite:setLocalInt("cdtweaksSpontaneousCast", 0) -- cannot be used in conjunction with the Cleric Spontaneous Cast feat
	end
	--
	return EEex_Actionbar_GetOp214ButtonDataItr(EEex_Utility_SelectItr(3, EEex_Utility_FilterItr(
		EEex_Utility_ChainItrs(
			CGameSprite:getKnownPriestSpellsWithAbilityIterator(1, 7 - EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])),
			CGameSprite:getKnownMageSpellsWithAbilityIterator(1, 9 - EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"]))
		),
		function(spellLevel, knownSpellIndex, spellResRef, spellHeader, spellAbility)
			local isSpellMemorized = EEex_Trigger_ParseConditionalString(string.format('HaveSpellRES("%s")', spellResRef))
			local toReturn = false
			--
			if isSpellMemorized:evalConditionalAsAIBase(CGameSprite) then
				-- effects that don't go through the projectile, like Target = Self, won't mutated by the op408
				if not GT_Metamagic_SelfBuff(spellHeader, spellAbility, EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])) then
					toReturn = true
				end
			end
			--
			isSpellMemorized:free()
			return toReturn
		end
	)))
end
