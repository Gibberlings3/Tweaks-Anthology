--[[
+-------------------------------------------------------------------------+
| cdtweaks: NWN-ish Spellcraft / Counterspell class feat for spellcasters |
+-------------------------------------------------------------------------+
--]]

local isSpontaneousCaster = {
	[19] = true, -- SORCERER
	[21] = true, -- SHAMAN
}

--

local counterSpellOppositionSchool = { -- based on iwdee
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

local counterSpellUniversalCounter = {
	["CLERIC_DISPEL_MAGIC"] = true,
	["WIZARD_REMOVE_MAGIC"] = true,
	["WIZARD_DISPEL_MAGIC"] = true,
	["WIZARD_TRUE_DISPEL_MAGIC"] = true,
}

--

local actionSources = {
	[31] = true, -- Spell()
	[95] = true, -- SpellPoint()
	[191] = true, -- SpellNoDec()
	[192] = true, -- SpellPointNoDec()
	[113] = true, -- ForceSpell()
	[114] = true, -- ForceSpellPoint()
	--[181] = true, -- ReallyForceSpell()
	[318] = true, -- ForceSpellRange()
	[319] = true, -- ForceSpellPointRange()
	--[337] = true, -- ReallyForceSpellPoint()
	[476] = true, -- EEex_SpellObjectOffset()
	[477] = true, -- EEex_SpellObjectOffsetNoDec()
	[478] = true, -- EEex_ForceSpellObjectOffset()
	--[479] = true, -- EEex_ReallyForceSpellObjectOffset()
}

-- make sure the checking for counterspelling is done only once --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local aux = EEex_GetUDAux(sprite)
	if actionSources[action.m_actionID] then
		aux["gt_NWN_CounterSpell_ActionStarted"] = true
	else
		if aux["gt_NWN_CounterSpell_ActionStarted"] then
			aux["gt_NWN_CounterSpell_ActionStarted"] = nil
		end
	end
end)

--

local function getCounterSpellSchool(spellLevel, isCantrip, spellResRef, spellSchool, sprite, spellLevelMemListArray)
	local maxCantripsPerDay = sprite:getLocalInt("gtNWNMaxCantripsPerDay")
	local curCantripsPerDay = sprite:getLocalInt("gtNWNCurCantripsPerDay")
	--
	local align = GT_Resource_SymbolToIDS["align"]
	-- cantrips need special treatment (i.e., if this is a cantrip, check if it can be countered by another cantrip)
	if spellLevel == 0 and isCantrip and curCantripsPerDay < maxCantripsPerDay then
		local array = EEex_Resource_Load2DA("GT#CNTRP")
		local nX, nY = array:getDimensions()
		nX = nX - 2
		nY = nY - 1
		-- get caster type
		local mxspl = sprite:getLocalString("gtNWNCantripsMXSPL")
		--
		for rowIndex = 0, nY do
			local res = EEex_Resource_GetAt2DAPoint(array, 1, rowIndex)
			local pHeader = EEex_Resource_Demand(res, "spl")
			local spellType = pHeader.itemType
			local exclusionFlags = pHeader.notUsableBy
			--
			if spellType == 2 then -- priest
				if string.find(mxspl, "PRS", 1, true) or (mxspl == "DRU" or mxspl == "SHM") then
					-- alignment check
					if EEex_IsBitUnset(exclusionFlags, 0x0) or not GT_Sprite_CheckIDS(sprite, align["MASK_CHAOTIC"], 8) then
						if EEex_IsBitUnset(exclusionFlags, 0x1) or not GT_Sprite_CheckIDS(sprite, align["MASK_EVIL"], 8) then
							if EEex_IsBitUnset(exclusionFlags, 0x2) or not GT_Sprite_CheckIDS(sprite, align["MASK_GOOD"], 8) then
								if EEex_IsBitUnset(exclusionFlags, 0x3) or not GT_Sprite_CheckIDS(sprite, align["MASK_LCNEUTRAL"], 8) then
									if EEex_IsBitUnset(exclusionFlags, 0x4) or not GT_Sprite_CheckIDS(sprite, align["MASK_LAWFUL"], 8) then
										if EEex_IsBitUnset(exclusionFlags, 0x5) or not GT_Sprite_CheckIDS(sprite, align["MASK_GENEUTRAL"], 8) then
											-- class check
											if EEex_IsBitUnset(exclusionFlags, 30) or not string.find(mxspl, "PRS", 1, true) then
												if EEex_IsBitUnset(exclusionFlags, 31) or not (mxspl == "DRU" or mxspl == "SHM") then
													return pHeader.school, true, spellLevel
												end
											end
										end
									end
								end
							end
						end
					end
				end
			elseif spellType == 1 then -- wizard
				if string.find(mxspl, "WIZ", 1, true) or (mxspl == "SRC" or mxspl == "DD") then
					return pHeader.school, true, spellLevel
				end
			end
		end
	end
	-- normal (i.e. memorizable) spells
	local memList = spellLevelMemListArray:getReference(spellLevel - 1) -- count starts from 0, that's why ``-1``
	local school = -1
	local flag = false
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
				if memSymbol and counterSpellUniversalCounter[memSymbol] then
					if not isSpontaneousCaster[sprite.m_typeAI.m_Class] then
						memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
					end
					school = memInstanceHeader.school
					return true
				end
			end
			-- resref counter
			if memInstanceResref == spellResRef then
				if not isSpontaneousCaster[sprite.m_typeAI.m_Class] then
					memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
				end
				school = memInstanceHeader.school
				return true
			end
			-- mschool counter
			for _, mschool in ipairs(counterSpellOppositionSchool[spellSchool][1]) do
				if mschool == memInstanceHeader.school then
					if not isSpontaneousCaster[sprite.m_typeAI.m_Class] then
						memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
					end
					school = memInstanceHeader.school
					return true
				end
			end
		end
	end)
	--
	return school, flag, spellLevel
end
	
-- check if there is someone casting a wizard/priest spell --
-- perform a counterspell if appropriate --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local state = GT_Resource_SymbolToIDS["state"]
	--
	local aux = EEex_GetUDAux(sprite)
	--
	local m_curAction = sprite.m_curAction -- CAIAction
	local spriteActiveStats = EEex_Sprite_GetActiveStats(sprite)
	--
	if actionSources[m_curAction.m_actionID] and sprite.m_bInCasting == 1 and aux["gt_NWN_CounterSpell_ActionStarted"] then -- make sure the spell action has started the casting glow
		aux["gt_NWN_CounterSpell_ActionStarted"] = nil
		--
		local findObjects = {}
		--
		local spellResRef = m_curAction.m_string1.m_pchData:get()
		if spellResRef == "" then
			spellResRef = GT_Utility_DecodeSpell(m_curAction.m_specificID)
		end
		-- check if cantrip (in case my other component about cantrips is installed...)
		local isCantrip = string.match(spellResRef:upper(), "^GTPR0[0-9][0-9]$") or string.match(spellResRef:upper(), "^GTWI0[0-9][0-9]$")
		--
		local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
		local spellType = spellHeader.itemType
		local spellSchool = spellHeader.school
		local spellLevel = spellHeader.spellLevel
		--
		if (spellType == 1 or spellType == 2) and (spellSchool > 0 and spellSchool <= 8) then -- sanity check
			--
			if sprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
				findObjects = EEex_Sprite_GetAllOfTypeInRange(sprite, GT_AI_ObjectType["GOODCUTOFF"], 448, nil, nil, nil) -- we intentionally ignore STATE_BLIND
			elseif sprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
				findObjects = EEex_Sprite_GetAllOfTypeInRange(sprite, GT_AI_ObjectType["EVILCUTOFF"], 448, nil, nil, nil) -- we intentionally ignore STATE_BLIND
			end
			--
			local found = -1
			local counteredByCantrip = false
			local lvl = -1
			--
			for _, itrSprite in ipairs(findObjects) do
				if itrSprite:getLocalInt("gtNWNCounterSpell") == 1 then
					local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
					-- lore-based check (a lore score of 240+ => automatic success)
					if itrSpriteActiveStats.m_nLore >= spellLevel * 10 + math.random(150) then
						--
						if EEex_BAnd(itrSpriteActiveStats.m_generalState, state["CD_STATE_NOTVALID"]) == 0 then
							--
							if EEex_IsBitUnset(spriteActiveStats.m_generalState, 0x4) or itrSpriteActiveStats.m_bSeeInvisible > 0 then
								-- deafness => extra check
								if not EEex_Sprite_GetSpellState(itrSprite, 0x26) or math.random(0, 1) == 1 then 
									-- provide feedback if PC
									if itrSprite.m_typeAI.m_EnemyAlly == 2 then
										GT_Sprite_DisplayMessage(itrSprite,
											string.format("%s : %s %s %s",
												Infinity_FetchString(%feedback_strref_spellcraft%), sprite:getName(), Infinity_FetchString(%feedback_strref_is_casting%), Infinity_FetchString(spellHeader.genericName)),
											0x6D4C95 -- Light Purple
										)
									end
									-- check if ``itrSprite`` is counterspelling...
									if spriteActiveStats.m_bSanctuary == 0 and EEex_Sprite_GetCastTimer(itrSprite) == -1 and itrSprite:getLocalInt("gtNWNCounterSpellMode") == 1 and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 12) then
										local spellLevelMemListTable = {[7] = itrSprite.m_memorizedSpellsPriest, [9] = itrSprite.m_memorizedSpellsMage}
										--
										for maxLevel, spellLevelMemListArray in pairs(spellLevelMemListTable) do
											for i = spellLevel, maxLevel do
												found, counteredByCantrip, lvl = getCounterSpellSchool(i, isCantrip, spellResRef, spellSchool, itrSprite, spellLevelMemListArray)
												--
												if found > 0 then
													goto found
												end
											end
										end
										--
										::found::
										--
										if found > 0 then
											-- sorcerer / shaman: remove a single active memorization instance of each unique spell
											if isSpontaneousCaster[itrSprite.m_typeAI.m_Class] then
												if lvl > 0 then
													local spellLevelMemListArray
													--
													if itrSprite.m_typeAI.m_Class == 19 then -- SORCERER
														spellLevelMemListArray = itrSprite.m_memorizedSpellsMage
													else
														spellLevelMemListArray = itrSprite.m_memorizedSpellsPriest
													end
													--
													local alreadyDecreasedResrefs = {}
													local memList = spellLevelMemListArray:getReference(lvl - 1)
													--
													EEex_Utility_IterateCPtrList(memList, function(memInstance)
														local memInstanceResref = memInstance.m_spellId:get()
														--
														if not alreadyDecreasedResrefs[memInstanceResref] then
															local memFlags = memInstance.m_flags
															--
															if EEex_IsBitSet(memFlags, 0) then
																memInstance.m_flags = EEex_UnsetBit(memFlags, 0)
																--
																alreadyDecreasedResrefs[memInstanceResref] = true
															end
														end
													end)
												end
											end
											-- check for Spell Immunity and Spell Turning
											if not GT_Sprite_HasBounceEffects(sprite, 0, 0, found, 0, counterSpellOppositionSchool[found][2], {-1}, 0) then
												if not GT_Sprite_HasImmunityEffects(sprite, 0, 0, found, 0, counterSpellOppositionSchool[found][2], {-1}, 0, 0, 0x0) then
													-- remove spell (so as to cancel the spell being cast)
													if not isCantrip then
														m_curAction.m_actionID = 147 -- RemoveSpell()
													else
														m_curAction.m_actionID = 0 -- NoAction()
													end
												end
											end
											-- perform counterspell
											sprite:applyEffect({
												["effectID"] = 146, -- Cast spell
												["res"] = counterSpellOppositionSchool[found][2],
												["sourceID"] = itrSprite.m_id,
												["sourceTarget"] = sprite.m_id,
											})
											--
											if counteredByCantrip then
												local curCantripsPerDay = itrSprite:getLocalInt("gtNWNCurCantripsPerDay")
												itrSprite:setLocalInt("gtNWNCurCantripsPerDay", curCantripsPerDay + 1)
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
			--
			::continue::
		end
	end
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
		CGameSprite:setLocalInt("gtNWNCounterSpellMode", 1)
	elseif CGameEffect.m_effectAmount == 2 then
		CGameSprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%INNATE_COUNTERSPELL%",
			["sourceID"] = CGameSprite.m_id,
			["sourceTarget"] = CGameSprite.m_id,
		})
		--
		CGameSprite:setLocalInt("gtNWNCounterSpellMode", 0)
	end
end

-- Make sure it cannot be disrupted. Cancel mode if no longer idle --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local counterSpellResRef = {
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
	if sprite:getLocalInt("gtNWNCounterSpell") == 1 then
		if sprite:getLocalInt("gtNWNCounterSpellMode") == 0 then
			if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%INNATE_COUNTERSPELL%" then
				action.m_actionID = 113 -- ForceSpell()
			end
		else
			if not (action.m_actionID == 113 and (counterSpellResRef[action.m_string1.m_pchData:get()] or action.m_string1.m_pchData:get() == "%INNATE_COUNTERSPELL%Y")) then
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
