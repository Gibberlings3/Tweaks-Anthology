-- cdtweaks, spontaneous cast for clerics: clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

function GTSPCAST(CGameEffect, CGameSprite)
	return EEex_Actionbar_GetOp214ButtonDataItr(EEex_Utility_SelectItr(3, EEex_Utility_FilterItr(
		EEex_Utility_ChainItrs(
			CGameSprite:getKnownPriestSpellsWithAbilityIterator(1, 7)
		),
		function(spellLevel, knownSpellIndex, spellResRef, spellHeader, spellAbility)
			if string.match(spellResRef:upper(), "^SPPR[1-7][0-9][0-9]$") then
				if string.match(spellResRef:sub(-2), "[0-4][0-9]") or string.match(spellResRef:sub(-2), "50") then -- NB.: Lua does not have regular expressions (that is to say, no "word boundary" matcher (\b), no alternatives (|), and also no lookahead or similar)!!!
					local spellIDS = 1 .. spellResRef:sub(-3)
					local symbol = GT_Resource_IDSToSymbol["spell"][tonumber(spellIDS)]
					--
					if symbol then
						if CGameEffect.m_effectAmount == 1 then
							return (symbol == "CLERIC_CURE_LIGHT_WOUNDS" or symbol == "CLERIC_CURE_MODERATE_WOUNDS" or symbol == "CLERIC_CURE_MEDIUM_WOUNDS" or symbol == "CLERIC_CURE_SERIOUS_WOUNDS" or symbol == "CLERIC_CURE_CRITICAL_WOUNDS")
						elseif CGameEffect.m_effectAmount == 2 then
							return (symbol == "CLERIC_CAUSE_LIGHT_WOUNDS" or symbol == "CLERIC_CAUSE_MODERATE_WOUNDS" or symbol == "CLERIC_CAUSE_MEDIUM_WOUNDS" or symbol == "CLERIC_CAUSE_SERIOUS_WOUNDS" or symbol == "CLERIC_CAUSE_CRITICAL_WOUNDS")
						end
					end
				end
			end
		end
	)))
end
