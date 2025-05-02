--[[
+-------------------------------------------------------------------------+
| cdtweaks: NWN-ish Spellcraft / Counterspell class feat for spellcasters |
+-------------------------------------------------------------------------+
--]]

local cdtweaks_Counterspell_ResRef = {
	["%INNATE_COUNTERSPELL%A"] = true,
	["%INNATE_COUNTERSPELL%B"] = true,
	["%INNATE_COUNTERSPELL%C"] = true,
	["%INNATE_COUNTERSPELL%D"] = true,
	["%INNATE_COUNTERSPELL%E"] = true,
	["%INNATE_COUNTERSPELL%F"] = true,
	["%INNATE_COUNTERSPELL%G"] = true,
	["%INNATE_COUNTERSPELL%H"] = true,
}

--

local cdtweaks_Counterspell_OppositionSchool = { -- based on iwdee
	[1] = {{5, 8}, "%INNATE_COUNTERSPELL%A"}, -- ABJURER countered by ILLUSIONIST and TRANSMUTER
	[2] = {{3, 6}, "%INNATE_COUNTERSPELL%B"}, -- CONJURER countered by DIVINER and INVOKER
	[3] = {{6}, "%INNATE_COUNTERSPELL%C"}, -- DIVINER countered by INVOKER
	[4] = {{7}, "%INNATE_COUNTERSPELL%D"}, -- ENCHANTER countered by NECROMANCER
	[5] = {{1, 7}, "%INNATE_COUNTERSPELL%E"}, -- ILLUSIONIST countered by ABJURER and NECROMANCER
	[6] = {{2, 4}, "%INNATE_COUNTERSPELL%F"}, -- INVOKER countered by CONJURER and ENCHANTER
	[7] = {{5, 8}, "%INNATE_COUNTERSPELL%G"}, -- NECROMANCER countered by ILLUSIONIST and TRANSMUTER
	[8] = {{1}, "%INNATE_COUNTERSPELL%H"}, -- TRANSMUTER countered by ABJURER
}

--

local cdtweaks_Counterspell_UniversalCounter = {
	["CLERIC_DISPEL_MAGIC"] = true,
	["WIZARD_REMOVE_MAGIC"] = true,
	["WIZARD_DISPEL_MAGIC"] = true,
	["WIZARD_TRUE_DISPEL_MAGIC"] = true,
}

-- check if there is someone casting a wizard/priest spell --
-- perform a counterspell if appropriate --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local state = GT_Resource_SymbolToIDS["state"]
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local spriteActiveStats = EEex_Sprite_GetActiveStats(sprite)
	-- alignment check
	local isGood = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_GOOD)")
	--
	local actionSources = {
		[31] = true, -- Spell()
		[95] = true, -- SpellPoint()
		[191] = true, -- SpellNoDec()
		[192] = true, -- SpellPointNoDec()
		[113] = true, -- ForceSpell()
		[114] = true, -- ForceSpellPoint()
		[181] = true, -- ReallyForceSpell()
		[318] = true, -- ForceSpellRange()
		[319] = true, -- ForceSpellPointRange()
		[337] = true, -- ReallyForceSpellPoint()
		[476] = true, -- EEex_SpellObjectOffset()
		[477] = true, -- EEex_SpellObjectOffsetNoDec()
		[478] = true, -- EEex_ForceSpellObjectOffset()
		[479] = true, -- EEex_ReallyForceSpellObjectOffset()
	}
	--
	if actionSources[action.m_actionID] then
		local spriteArray = {}
		--
		local spellResRef = action.m_string1.m_pchData:get()
		if spellResRef == "" then
			spellResRef = GT_Utility_DecodeSpell(action.m_specificID)
		end
		-- check if cantrip (in case my other component about cantrips is installed...)
		local isCantrip = string.match(spellResRef:upper(), "^GTPR0[0-9][0-9]$") or string.match(spellResRef:upper(), "^GTWI0[0-9][0-9]$")
		local spriteCantripsPerDay = sprite:getLocalInt("gtCantripsPerDay")
		--
		local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
		local spellType = spellHeader.itemType
		local spellSchool = spellHeader.school
		local spellLevel = spellHeader.spellLevel
		--
		if (spellType == 1 or spellType == 2) and (spellSchool > 0 and spellSchool <= 8) then
			--
			if sprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeInRange(sprite, GT_AI_ObjectType["GOODCUTOFF"], 448, nil, nil, nil) -- we intentionally ignore STATE_BLIND
			elseif sprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
				spriteArray = EEex_Sprite_GetAllOfTypeInRange(sprite, GT_AI_ObjectType["EVILCUTOFF"], 448, nil, nil, nil) -- we intentionally ignore STATE_BLIND
			end
			--
			local found = -1
			--
			for _, itrSprite in ipairs(spriteArray) do
				if itrSprite:getLocalInt("gtCounterSpell") == 1 then
					local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
					-- lore-based check (a lore score of 240+ => automatic success)
					if itrSpriteActiveStats.m_nLore >= spellLevel * 10 + math.random(150) then
						if EEex_BAnd(itrSpriteActiveStats.m_generalState, state["CD_STATE_NOTVALID"]) == 0 then
							if EEex_IsBitUnset(spriteActiveStats.m_generalState, 0x4) or itrSpriteActiveStats.m_bSeeInvisible > 0 then
								-- deafness => extra check
								if not EEex_Sprite_GetSpellState(itrSprite, 0x26) or math.random(0, 1) == 1 then 
									-- provide feedback if PC
									if itrSprite.m_typeAI.m_EnemyAlly == 2 then
										GT_Utility_DisplaySpriteMessage(itrSprite,
											string.format("%s : %s %s %s",
												Infinity_FetchString(%feedback_strref_spellcraft%), sprite:getName(), Infinity_FetchString(%feedback_strref_is_casting%), Infinity_FetchString(spellHeader.genericName)),
											0xBED7D7, 0xBED7D7 -- 
										)
									end
									-- check if ``itrSprite`` is counterspelling...
									if spriteActiveStats.m_bSanctuary == 0 and EEex_Sprite_GetCastTimer(itrSprite) == -1 and itrSprite:getLocalInt("gtCounterSpellMode") == 1 and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 12) then
										local spellLevelMemListTable = {[7] = itrSprite.m_memorizedSpellsPriest, [9] = itrSprite.m_memorizedSpellsMage}
										--
										local itrSpriteCantripsPerDay = itrSprite:getLocalInt("gtCantripsPerDay")
										local counteredByCantrip = false
										--
										for maxLevel, spellLevelMemListArray in pairs(spellLevelMemListTable) do
											for i = spellLevel, maxLevel do
												-- cantrips need special treatment (i.e., if this is a cantrip, check if it can be countered by another cantrip)
												if i == 0 and isCantrip and itrSpriteCantripsPerDay > 0 then
													local array = EEex_Resource_Load2DA("GT#CNTRP")
													local nX, nY = array:getDimensions()
													nX = nX - 2
													nY = nY - 1
													-- get caster type (bit0 -> priest, bit1 -> wizard)
													local casterType = itrSprite:getLocalInt("gtCantripsCasterType")
													-- class check
													local mxspl = itrSprite:getLocalString("gtCantripsMXSPL")
													--
													for rowIndex = 0, nY do
														local res = EEex_Resource_GetAt2DAPoint(array, 1, rowIndex)
														local pHeader = EEex_Resource_Demand(res, "spl")
														local ids = pHeader.itemType == 1 and 2 .. res:sub(-3) or 1 .. res:sub(-3)
														local symbol = GT_Resource_IDSToSymbol["gtspell"][tonumber(ids)]
														--
														if pHeader.itemType == 2 then -- priest
															if EEex_IsBitSet(casterType, 0x0) then
																if symbol:upper() ~= "CLERIC_CAUSE_MINOR_WOUNDS" or (not isGood:evalConditionalAsAIBase(itrSprite) and string.find(mxspl, "MXSPLPRS", 1, true)) then -- neutral or evil clerics only
																	if symbol:upper() ~= "CLERIC_FLARE" or (mxspl == "MXSPLDRU" or mxspl == "MXSPLSHM") then -- druids/shamans only
																		if symbol:upper() ~= "CLERIC_THORN_WHIP" or (mxspl == "MXSPLDRU" or mxspl == "MXSPLSHM") then -- druids/shamans only
																			if symbol:upper() ~= "CLERIC_BLADE_WARD" or string.find(mxspl, "MXSPLPRS", 1, true) then -- clerics only
																				if res:upper() == spellResRef:upper() then
																					counteredByCantrip = true
																					found = pHeader.school
																					goto found
																				else
																					for _, mschool in ipairs(cdtweaks_Counterspell_OppositionSchool[spellSchool][1]) do
																						if mschool == pHeader.school then
																							counteredByCantrip = true
																							found = pHeader.school
																							goto found
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														elseif pHeader.itemType == 1 then -- wizard
															if EEex_IsBitSet(casterType, 0x1) then
																if res:upper() == spellResRef:upper() then
																	counteredByCantrip = true
																	found = pHeader.school
																	goto found
																else
																	for _, mschool in ipairs(cdtweaks_Counterspell_OppositionSchool[spellSchool][1]) do
																		if mschool == pHeader.school then
																			counteredByCantrip = true
																			found = pHeader.school
																			goto found
																		end
																	end
																end
															end
														end
													end
												end
												-- normal (i.e. memorizable) spells
												local memList = spellLevelMemListArray:getReference(i - 1) -- count starts from 0, that's why ``-1``
												--
												EEex_Utility_IterateCPtrList(memList, function(memInstance)
													local memInstanceResref = memInstance.m_spellId:get()
													local memFlags = memInstance.m_flags
													--
													if EEex_IsBitSet(memFlags, 0x0) then -- if memorized, ...
														local memInstanceHeader = EEex_Resource_Demand(memInstanceResref, "SPL")
														-- universal counters
														if string.match(memInstanceResref:upper(), "^SPPR[1-7][0-9][0-9]$") or string.match(memInstanceResref:upper(), "^SPWI[1-9][0-9][0-9]$") then
															local memIDS = memInstanceHeader.itemType == 1 and 2 .. memInstanceResref:sub(-3) or 1 .. memInstanceResref:sub(-3)
															local memSymbol = GT_Resource_IDSToSymbol["spell"][tonumber(memIDS)]
															--
															if memSymbol and cdtweaks_Counterspell_UniversalCounter[memSymbol] then
																memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
																found = memInstanceHeader.school
																return true
															end
														end
														-- resref counter
														if memInstanceResref == spellResRef then
															memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
															found = memInstanceHeader.school
															return true
														end
														-- mschool counter
														for _, mschool in ipairs(cdtweaks_Counterspell_OppositionSchool[spellSchool][1]) do
															if mschool == memInstanceHeader.school then
																memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
																found = memInstanceHeader.school
																return true
															end
														end
													end
												end)
												--
												::found::
												if found > 0 then
													-- check for Spell Immunity and friends
													local hasBounceEffects = false
													local hasImmunityEffects = false
													--
													local testSchool = function(effect)
														if (effect.m_effectId == 0xCC or effect.m_effectId == 0xDF) and effect.m_dWFlags == found then -- Protection from spell school (204) / Spell school deflection (223)
															hasImmunityEffects = true
															return true
														elseif (effect.m_effectId == 0xCA or effect.m_effectId == 0xE3) and effect.m_dWFlags == found then -- Reflect spell school (202) / Spell school turning (227)
															hasBounceEffects = true
															return true
														end
													end
													--
													EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, testSchool)
													if not (hasBounceEffects or hasImmunityEffects) then
														EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, testSchool)
													end
													--
													if not (hasBounceEffects or hasImmunityEffects) then
														-- remove spell (so as to cancel the spell being cast)
														if not isCantrip then
															action.m_actionID = 147 -- RemoveSpell()
														else
															action.m_actionID = 0 -- NoAction()
															--
															sprite:setLocalInt("gtCantripsPerDay", spriteCantripsPerDay - 1)
														end
													end
													-- perform counterspell
													sprite:applyEffect({
														["effectID"] = 146, -- Cast spell
														["res"] = cdtweaks_Counterspell_OppositionSchool[found][2],
														["sourceID"] = itrSprite.m_id,
														["sourceTarget"] = sprite.m_id,
													})
													--
													if counteredByCantrip then
														itrSprite:setLocalInt("gtCantripsPerDay", itrSpriteCantripsPerDay - 1)
													end
													-- op146*p2=0 corresponds to 'ForceSpell()', so we have to manually set the aura
													itrSprite.m_castCounter = 0
													--
													goto continue
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			--
			::continue::
		end
	end
	--
	isGood:free()
end)

-- Mark the sprite as being in counterspell mode. Automatically cancel mode upon death --

function %INNATE_COUNTERSPELL%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		-- we apply effects here due to op232's presence (which for best results requires EFF V2.0)
		local effectCodes = {
			{["op"] = 321, ["res"] = "%INNATE_COUNTERSPELL%"}, -- remove effects by resource
			{["op"] = 232, ["p2"] = 16, ["res"] = "%INNATE_COUNTERSPELL%Z"}, -- cast spl on condition (condition: Die(); target: self)
			{["op"] = 142, ["p2"] = %feedback_icon%}, -- feedback icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["durationType"] = 1,
				["m_sourceRes"] = "%INNATE_COUNTERSPELL%",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
		--
		CGameSprite:setLocalInt("gtCounterspellMode", 1)
	elseif CGameEffect.m_effectAmount == 2 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%INNATE_COUNTERSPELL%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		--
		CGameSprite:setLocalInt("gtCounterspellMode", 0)
	end
end

-- Make sure it cannot be disrupted. Cancel mode if no longer idle --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksSpellcraft") == 1 then
		if sprite:getLocalInt("gtCounterspellMode") == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%INNATE_COUNTERSPELL%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		else
			if not (action.m_actionID == 113 and (cdtweaks_Counterspell_ResRef[action.m_string1.m_pchData:get()] or action.m_string1.m_pchData:get() == "%INNATE_COUNTERSPELL%Y")) then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%INNATE_COUNTERSPELL%Z",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)
