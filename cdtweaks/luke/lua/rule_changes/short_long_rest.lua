--[[
+----------------------------------------------------+
| cdtweaks, Short Rest (at most twice per long rest) |
+----------------------------------------------------+
--]]

-- Camp supplies --

GT_TweaksAnthology_CampSupplies = {
	["GTFOOD00"] = 5, -- baguette
	["GTFOOD01"] = 3, -- biscuit
	["GTFOOD02"] = 12, -- boiled beholder eyestalks
	["GTFOOD03"] = 4, -- boiled potato
	["GTFOOD04"] = 3, -- chicken egg
	["GTFOOD05"] = 4, -- fish fillet
	["GTFOOD06"] = 8, -- grilled steak
	["GTFOOD07"] = 5, -- honey comb
	["GTFOOD08"] = 2, -- kiwi
	["GTFOOD09"] = 40, -- owlbear egg
	["GTFOOD10"] = 4, -- pig's head
	["GTFOOD11"] = 10, -- pork shoulder
	["GTFOOD12"] = 12, -- pumpkin
	["GTFOOD13"] = 10, -- raw steak
	["GTFOOD14"] = 15, -- roast pork
	["GTFOOD15"] = 15, -- roast turkey
	["GTFOOD16"] = 20, -- salmon pie
	["GTFOOD17"] = 7, -- vegetable broth
	["GTFOOD18"] = 5, -- vegetable soup
	["GTFOOD19"] = 5, -- white bread
}

-- Main logic --

function GT_TweaksAnthology_ShortLongRest(mode)
	if mode == 0x0 then -- cancel
		-- unpause the game
		if worldScreen:CheckIfPaused() then
			worldScreen:TogglePauseGame(false)
		end
	elseif mode == 0x1 then -- short rest
		-- check if can rest (no enemies nearby, in control of all your party members, at most two short rests per long rest)
		local triggerList = {
			EEex_Trigger_ParseConditionalString("!ActuallyInCombat()"), -- out of combat
			EEex_Trigger_ParseConditionalString("CombatCounter(0)"), -- out of combat
			EEex_Trigger_ParseConditionalString("!StateCheck(Myself,0x801020EF)"), -- in control of all your party members
			EEex_Trigger_ParseConditionalString('GlobalLT("gtTweaksShortRest", "LOCALS", 2)'), -- at most two short rests per long rest
		}
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				for j, trigger in ipairs(triggerList) do
					if not trigger:evalConditionalAsAIBase(partyMember) then
						local feedback
						if j == 1 or j == 2 then
							feedback = EEex_Resource_2DA("ENGINEST", "STRREF_GUI_MIXED_CANNOTRESTMONSTERS", "StrRef")
						elseif j == 3 then
							feedback = EEex_Resource_2DA("ENGINEST", "STRREF_GUI_MIXED_CANNOTRESTOUTOFCONTROL", "StrRef")
						else
							feedback = %strref_short_rest_limit%
						end
						Infinity_DisplayString("^R" .. Infinity_FetchString(tonumber(feedback)) .. "^-")
						return
					end
				end
			end
		end
		-- check if can rest (party members not scattered around)
		local player1 = EEex_Sprite_GetInPortrait(0) -- CGameSprite
		if EEex_Area_CountAllOfTypeInRange(player1.m_pArea, player1.m_pos.x, player1.m_pos.y, EEex_Object_ParseString("[PC]"), 256) ~= EEex_Sprite_GetNumCharacters() then
			Infinity_DisplayString("^R" .. Infinity_FetchString(tonumber(EEex_Resource_2DA("ENGINEST", "STRREF_GUI_MIXED_CANNOTRESTSCATTERED", "StrRef"))) .. "^-")
			return
		end
		-- actual rest
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				-- recover only 50% of fatigue
				local fatigue = partyMember:getActiveStats().m_nFatigue
				partyMember:applyEffect({
					["effectID"] = 0x5D, -- Fatigue bonus (93)
					["effectAmount"] = fatigue > 0 and (-1 * math.floor(fatigue / 2)) or 0,
					["durationType"] = 1,
					["noSave"] = true, -- just in case...
					["sourceID"] = partyMember.m_id,
					["sourceTarget"] = partyMember.m_id,
				})
				-- 100% chance to recover **one** wizard/priest spell to memory, +75% chance to recover a second one
				for spellType = 0, 1 do -- wizard, priest
					for spellLevel = 1, (spellType == 0 and 9 or 7) do
						for _ = 1, (math.random() < 0.75 and 2 or 1) do -- ``math.random()`` returns a float in [0, 1), so < 0.75 gives exactly a 75% chance
							partyMember:applyEffect({
								["effectID"] = 0x105, -- Restore lost spells (261)
								["effectAmount"] = spellLevel,
								["dwFlags"] = spellType,
								["special"] = 0x3, -- randomly choose the spell + do **not** restore a spell at the next lowest level possible
								["noSave"] = true, -- just in case...
								["sourceID"] = partyMember.m_id,
								["sourceTarget"] = partyMember.m_id,
							})
						end
					end
				end
				-- 100% chance to restore all innate abilities to memory
				local spellLevelMemListArray = partyMember.m_memorizedSpellsInnate -- Array<CTypedPtrList<CPtrList, CCreatureFileMemorizedSpell*>,1>
				local memList = spellLevelMemListArray:getReference(0) -- CCreatureFileMemorizedSpell*
				EEex_Utility_IterateCPtrList(memList, function(memInstance) -- CCreatureFileMemorizedSpell
					local memInstanceResref = memInstance.m_spellId:get()
					local spellHeader = EEex_Resource_Demand(memInstanceResref, "SPL") -- Spell_Header_st
					-- sanity check
					if spellHeader then
						local spellType = spellHeader.itemType
						-- sanity check
						if not (spellType == 1 or spellType == 2) then
							local memFlags = memInstance.m_flags
							-- if spell already cast
							if EEex_IsBitUnset(memFlags, 0x0) then
								memInstance.m_flags = EEex_SetBit(memFlags, 0x0)
							end
						end
					end
				end)
			end
		end
		-- advance time by 4 hours
		C:Eval('ActionOverride(Player1Fill,AdvanceTime(1200))')
		Infinity_DisplayString("^C" .. Infinity_FetchString(%strref_short_rest_complete%) .. "^-")
	elseif mode == 0x2 then -- long rest
		-- check if enough camp supplies
		local found = false
		local required = 0
		local current = 0
		local isDungeon = EEex_IsBitSet(EEex_Sprite_GetInPortrait(0).m_pArea.m_header.m_areaType, 0x5)
		--
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				if not EEex_IsAtMostOneBitSet(partyMember:getActiveStats().m_generalState, 0xFC0) then -- !StateCheck(Myself,STATE_REALLY_DEAD)
					required = required + 10
				end
				local items = partyMember.m_equipment.m_items -- Array<CItem*,39>
				--
				for j = 18, 33 do -- inventory slots (as per SLOTS.IDS)
					local item = items:get(j) -- CItem
					if item then -- sanity check
						local resref = item.pRes.resref:get()
						--
						if resref == "GTSUPPAK" then
							found = true
						elseif GT_TweaksAnthology_CampSupplies[resref] then
							current = current + (GT_TweaksAnthology_CampSupplies[resref] * item.m_useCount1)
						end
					end
				end
			end
		end
		--
		if found then
			local store = EEex_Resource_Demand("GTSUPPAK", "STO") -- CStoreFileHeader
			if store then -- sanity check
				for item in store:getItemsItr() do -- CStoreFileItem
					if item then -- sanity check
						local resref = item.m_itemId:get()
						--
						if GT_TweaksAnthology_CampSupplies[resref] then
							current = current + (GT_TweaksAnthology_CampSupplies[resref] * item.m_usageCount:get(0))
						end
					end
				end
			end
		end
		--
		if isDungeon then
			required = required + ((required / 100) * 20) -- +20% in dungeons
		end
		--
		if not (current >= required) then
			popupInfo(%popupInfo%)
			return
		end
		-- set a global flag to prevent a loop when calling again the OnRestButtonClick() engine function
		EEex_GameState_SetGlobalInt("gtTweaksCampSupplies", required)
		e:GetActiveEngine():OnRestButtonClick()
	elseif mode == 0x3 then
		-- reset short rest attempts
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				EEex_Sprite_SetLocalInt(partyMember, "gtTweaksShortRest", 0)
			end
		end
		-- consume camp supplies
		if EEex_GameState_GetGlobalInt("gtTweaksCampSupplies") > 0 then
			local required = EEex_GameState_GetGlobalInt("gtTweaksCampSupplies")
			local found = false
			local current = 0
			EEex_GameState_SetGlobalInt("gtTweaksCampSupplies", 0)
			--
			for i = 0, 5 do
				local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
				if partyMember then -- sanity check
					local tbl = {}
					local items = partyMember.m_equipment.m_items -- Array<CItem*,39>
					--
					for j = 18, 33 do -- inventory slot (as per SLOTS.IDS)
						local item = items:get(j) -- CItem
						if item then -- sanity check
							local resref = item.pRes.resref:get()
							--
							if resref == "GTSUPPAK" then
								found = true
							elseif GT_TweaksAnthology_CampSupplies[resref] then
								table.insert(tbl, {["slotID"] = j, ["singleValue"] = GT_TweaksAnthology_CampSupplies[resref]})
							end
						end
					end
					-- sort by single value
					table.sort(tbl, function(a, b)
						return a.singleValue < b.singleValue
					end)
					--
					for _, entry in ipairs(tbl) do
						local item = items:get(entry.slotID) -- CItem
						if item then -- sanity check
							while (current < required and item.m_useCount1 > 0) do
								current = current + entry.singleValue
								--
								if item.m_useCount1 == 1 then
									partyMember:applyEffect({
										["effectID"] = 0x8F, -- Create item in slot (143)
										["effectAmount"] = entry.slotID,
										["res"] = "STAF01", -- some random item
										["noSave"] = true, -- just in case...
										["sourceID"] = partyMember.m_id,
										["sourceTarget"] = partyMember.m_id,
									})
								else
									item.m_useCount1 = item.m_useCount1 - 1
								end
							end
							--
							if current >= required then
								goto continue
							end
						end
					end
				end
			end
			-- check supply pack
			::continue::
			if found then
				if current < required then
					local store = EEex_Resource_Demand("GTSUPPAK", "STO") -- CStoreFileHeader
					if store then -- sanity check
						local tbl = {}
						--
						for item in store:getItemsItr() do -- CStoreFileItem
							if item then -- sanity check
								local resref = item.m_itemId:get()
								--
								if GT_TweaksAnthology_CampSupplies[resref] then
									table.insert(tbl, {["res"] = resref, ["singleValue"] = GT_TweaksAnthology_CampSupplies[resref], ["amount"] = item.m_usageCount:get(0)})
								end
							end
						end
						-- sort by single value
						table.sort(tbl, function(a, b)
							return a.singleValue < b.singleValue
						end)
						--
						for _, entry in ipairs(tbl) do
							while (entry.amount > 0 and current < required) do
								current = current + entry.singleValue
								--
								--C:Eval(string.format('ActionOverride(Player1Fill, RemoveStoreItem("GTSUPPAK", "%s", 1))', entry.res))
								--
								entry.amount = entry.amount - 1
							end
							--
							if current >= required then
								break
							end
						end
					end
				end
			end
		end
	end
end

-- Display a popup message: Short Rest vs Long Rest --

EEex_GameState_AddInitializedListener(function()
	-- CBaldurEngine
	local old = CBaldurEngine.OnRestButtonClick
	CBaldurEngine.OnRestButtonClick = function(...)
		if EEex_GameState_GetGlobalInt("gtTweaksCampSupplies") == 0 then
			-- return to main game screen
			e:GetActiveEngine():OnLeftPanelButtonClick(0)
			-- pause the game
			if not worldScreen:CheckIfPaused() then
				worldScreen:TogglePauseGame(true)
			end
			-- popup menu (3 buttons)
			popup3Button(
				%popup3Button%,
				"CANCEL_BUTTON", GT_TweaksAnthology_ShortLongRest(0x0),
				Infinity_FetchString(%midText%), GT_TweaksAnthology_ShortLongRest(0x1),
				Infinity_FetchString(%rightText%), GT_TweaksAnthology_ShortLongRest(0x2)
			)
		else
			old(...)
		end
	end
end)

