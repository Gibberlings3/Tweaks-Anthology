--[[
+----------------------------------------+
| cdtweaks, spontaneous cast for clerics |
+----------------------------------------+
--]]

-- clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

function %PRIEST_SPONTANEOUS_CAST%(CGameEffect, CGameSprite)
	local align = GT_Resource_SymbolToIDS["align"]
	local isEvil = GT_Sprite_CheckIDS(CGameSprite, align["MASK_EVIL"], 8)
	local isGood = GT_Sprite_CheckIDS(CGameSprite, align["MASK_GOOD"], 8)
	--
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
					if symbol then -- sanity check
						if symbol == "CLERIC_CURE_LIGHT_WOUNDS" or symbol == "CLERIC_CURE_MODERATE_WOUNDS" or symbol == "CLERIC_CURE_MEDIUM_WOUNDS" or symbol == "CLERIC_CURE_SERIOUS_WOUNDS" or symbol == "CLERIC_CURE_CRITICAL_WOUNDS" then -- good only
							if isGood then
								return true
							end
						elseif symbol == "CLERIC_CAUSE_LIGHT_WOUNDS" or symbol == "CLERIC_CAUSE_MODERATE_WOUNDS" or symbol == "CLERIC_CAUSE_MEDIUM_WOUNDS" or symbol == "CLERIC_CAUSE_SERIOUS_WOUNDS" or symbol == "CLERIC_CAUSE_CRITICAL_WOUNDS" then -- evil only
							if isEvil then
								return true
							end
						end
					end
				end
			end
		end
	)))
end

-- clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

EEex_Key_AddPressedListener(function(key)
	local sprite = EEex_Sprite_GetSelected()
	if not sprite then
		return
	end
	-- check for op145
	local spellcastingDisabled = GT_Sprite_SpellcastingDisabled(sprite, 0x2)
	--
	local lastState = EEex_Actionbar_GetLastState()
	local state = EEex_Actionbar_GetState()
	--
	local aux = EEex_GetUDAux(sprite)
	-- Check creature's class / flags
	local class = GT_Resource_SymbolToIDS["class"]
	-- single/multi/(complete)dual
	local isClericAll = GT_Sprite_CheckIDS(sprite, class["CLERIC_ALL"], 5)
	local canSpontaneouslyCast = isClericAll
	--
	if not spellcastingDisabled then -- op145 check...
		if canSpontaneouslyCast then
			if sprite.m_typeAI.m_EnemyAlly == 2 then -- [PC] check...
				if (lastState >= 1 and lastState <= 21) and (state == 103 or state == 113) then -- Cast Spell (F7) mode check...
					if EEex_Sprite_GetCastTimer(sprite) == -1 or sprite:getActiveStats().m_bAuraCleansing > 0 then -- aura check...
						if key == EEex_Key_GetFromName("Left Alt") then -- if the Left Alt key is pressed...
							sprite:applyEffect({
								["effectID"] = 214, -- select spell
								["dwFlags"] = 3, -- from lua
								["noSave"] = true,
								["res"] = "%PRIEST_SPONTANEOUS_CAST%",
								["sourceID"] = sprite.m_id,
								["sourceTarget"] = sprite.m_id,
							})
							--
							aux["gt_NWN_SpontaneousCast_Actionbar_LastState"] = lastState -- store it for later restoration
						end
					end
				end
			end
		end
	end
end)

-- check if the caster has at least 1 spell of appropriate level memorized (f.i. at least 1 spell of level 1 if it intends to spontaneously cast Cure/Cause Light Wounds). If so, decrement (unmemorize) all spells of that level by 1 --
-- restore the previous actionbar state after starting an action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local aux = EEex_GetUDAux(sprite)
	--
	if aux["gt_NWN_SpontaneousCast_Actionbar_LastState"] then
		if action.m_actionID == 191 then -- SpellNoDec()
			--
			local spellResRef = action.m_string1.m_pchData:get()
			if spellResRef == "" then
				spellResRef = GT_Utility_DecodeSpell(action.m_specificID)
			end
			local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
			local spellType = spellHeader.itemType
			local spellLevel = spellHeader.spellLevel
			--
			local spellLevelMemListArray
			if spellType == 2 then -- Priest
				spellLevelMemListArray = sprite.m_memorizedSpellsPriest
			end
			--
			local alreadyDecreasedResrefs = {}
			local memList = spellLevelMemListArray:getReference(spellLevel - 1)  -- count starts from 0, that's why ``-1``
			local found = false
			--
			EEex_Utility_IterateCPtrList(memList, function(memInstance)
				local memInstanceResref = memInstance.m_spellId:get()
				if not alreadyDecreasedResrefs[memInstanceResref] then
					local memFlags = memInstance.m_flags
					if EEex_IsBitSet(memFlags, 0x0) then -- if memorized, ...
						memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... unmemorize
						alreadyDecreasedResrefs[memInstanceResref] = true
						found = true
					end
				end
			end)
			--
			if not found then
				local feedbackStrRefs = {%strref1%, %strref2%, %strref3%, %strref4%, %strref5%}
				sprite:applyEffect({
					["effectID"] = 139, -- Display string
					["effectAmount"] = feedbackStrRefs[spellLevel],
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				-- abort action
				action.m_actionID = 0 -- NoAction()
			end
		end
		--
		if EEex_UDEqual(sprite, EEex_Sprite_GetSelected()) then
			EEex_Actionbar_SetState(aux["gt_NWN_SpontaneousCast_Actionbar_LastState"])
		end
		aux["gt_NWN_SpontaneousCast_Actionbar_LastState"] = nil
	end
end)

