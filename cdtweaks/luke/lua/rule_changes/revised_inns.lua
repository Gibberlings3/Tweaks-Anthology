--[[
+------------------------+
| cdtweaks, revised inns |
+------------------------+
--]]

EEex_GameState_AddInitializedListener(function()
	-- make the cost of renting a room in an inn scale with party level
	local old = CScreenStore.GetRoomCost -- This value is UI only!!!
	CScreenStore.GetRoomCost = function(...)
		-- determine the average level of the party by evaluating the LevelParty() conditional for each level until we find a match
		local modifier
		for i = 1, 1000 do
			local found = EEex_Trigger_ParseConditionalString(string.format("LevelParty(%d)", i))
			if found:evalConditionalAsAIBase(EEex_Sprite_GetInPortrait(0)) then
				modifier = i
			end
			if modifier then
				found:free()
				break
			end
		end
		-- sanity check
		if not (modifier and modifier >= 1) then
			EEex_Error("Failed to determine party level for the Revised Inns component!")
		end
		-- apply the modifier
		return (old(...) > 0) and (old(...) * modifier) or 0
	end
	-- store the chosen room type in a global variable for use in the rest of the component
	local old = CScreenStore.OnRentRoomButtonClick
	CScreenStore.OnRentRoomButtonClick = function(...)
		-- adjust real room cost to match the UI (displayed) room cost
		local roomCost = storeScreen:GetRoomCost()
		local roomType = storeScreen:GetRoomType()
		local diff
		local header = EngineGlobals.g_pBaldurChitin.m_pEngineStore.m_pStore.m_header -- CStoreFileHeader
		local partyGold = game:GetPartyGold()
		local canAfford = partyGold >= roomCost
		--
		EEex_Utility_Switch(roomType, {
			[1] = function()
				diff = roomCost - header.m_nRoomCostPeasant
			end,
			[2] = function()
				diff = roomCost - header.m_nRoomCostMerchant
			end,
			[3] = function()
				diff = roomCost - header.m_nRoomCostNoble
			end,
			[4] = function()
				diff = roomCost - header.m_nRoomCostRoyal
			end,
		}, function()
			EEex_Error(string.format("Invalid room type %d when executing revised inns OnRentRoomButtonClick() hook!", roomType))
		end)
		-- sanity check
		if not (diff and diff >= 0) then
			EEex_Error(string.format("Invalid room cost! Total cost: %d. Base cost: %d", roomCost, roomCost - diff))
		end
		--
		C:AddGold(-diff) -- op105 is associated with a feedback message. We use the cheat command to remove gold without triggering any message
		old(...) -- subtract base cost / trigger popup error messages (insufficient gold or whatever)
		-- If an error message was triggered, then the transaction did not go through and we should refund the party for the gold we removed to adjust the cost
		if Infinity_GetCurrentScreenName() == "" then -- no popup error message triggered, so we can store the room type for later use in the current world script
			EEex_GameState_SetGlobalInt("gtTweaksRevisedInnsRoomType", roomType)
		else
			C:AddGold(canAfford and diff or partyGold)
		end
	end
end)

-- room type -> bonuses --

function GT_TweaksAnthology_RevisedInns()
	local roomType = EEex_GameState_GetGlobalInt("gtTweaksRevisedInnsRoomType")
	local effectCodes = {}
	local saveTypes = {0x21, 0x22, 0x23, 0x24, 0x25} -- death (op33), wands (op34), polymorph (op35), breath (op36), spells (op37)
	local physicalAttrTypes = {0xA, 0xF, 0x2C} -- CON (op10), DEX (op15), STR (op44)
	local addPortraitIcon = true
	--
	if roomType == 1 then -- peasant
		local roll = Infinity_RandomNumber(1, 4) -- 1d4
		--
		EEex_Utility_Switch(roll, {
			[2] = function()
				effectCodes = {
					{["op"] = EEex_Utility_PickRandom(saveTypes)[1], ["p1"] = 1} -- +1 to a random save
				}
			end,
			[3] = function()
				effectCodes = {
					{["op"] = Infinity_RandomNumber(1, 2) == 1 and 0xA7 or 0x11C, ["p1"] = 1} -- +1 to hit: melee (op284) or ranged (op167)
				}
			end,
			[4] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 1 * EEex_Sprite_GetLevels(sprite).base.highest end} -- +1 HP per (base) character level
				}
				addPortraitIcon = false
			end,
		}, function()
			-- no bonus for roll 1, so do nothing
		end)
	elseif roomType == 2 then -- merchant
		local roll = Infinity_RandomNumber(1, 6) -- 1d6
		--
		EEex_Utility_Switch(roll, {
			[2] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end} -- +2 HP per (base) character level
				}
				addPortraitIcon = false
			end,
			[3] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end} -- +2 HP per (base) character level
				}
				addPortraitIcon = false
			end,
			[4] = function()
				effectCodes = {
					{["op"] = 0x116, ["p1"] = 1} -- +1 to hit (op278)
				}
			end,
			[5] = function()
				effectCodes = {
					{["op"] = 0x116, ["p1"] = 1} -- +1 to hit (op278)
				}
			end,
			[6] = function()
				effectCodes = {
					{["op"] = 0x145, ["p1"] = Infinity_RandomNumber(1, 20) == 10 and 2 or 1} -- +1 (+2 if lucky) to all saves (op325)
				}
			end,
		}, function()
			-- no bonus for roll 1, so do nothing
		end)
	elseif roomType == 3 then -- noble
		local roll = Infinity_RandomNumber(1, 6) -- 1d6
		--
		EEex_Utility_Switch(roll, {
			[1] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +2 HP per (base) character level
					{["op"] = 0x116, ["p1"] = 1} -- +1 to hit (op278)
				}
			end,
			[2] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +2 HP per (base) character level
					{["op"] = 0x116, ["p1"] = 1} -- +1 to hit (op278)
				}
			end,
			[3] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +2 HP per (base) character level
					{["op"] = 0x145, ["p1"] = 1} -- +1 to all saves (op325)
				}
			end,
			[4] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 2 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +2 HP per (base) character level
					{["op"] = 0x145, ["p1"] = 1} -- +1 to all saves (op325)
				}
			end,
			[5] = function()
				effectCodes = {
					{["op"] = 0xA, ["p1"] = 1} -- +1 CON (op10)
				}
			end,
			[6] = function()
				effectCodes = {
					{["op"] = Infinity_RandomNumber(1, 2) == 2 and 0xF or 0x2C, ["p1"] = 1} -- +1 DEX or STR (op15 / op44)
				}
			end,
		}, function()
			EEex_Error("Should not reach this point")
		end)
	elseif roomType == 4 then -- royal
		local roll = Infinity_RandomNumber(1, 6) -- 1d6
		--
		EEex_Utility_Switch(roll, {
			[1] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 3 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +3 HP per (base) character level
					{["op"] = 0x145, ["p1"] = 1} -- +1 to all saves (op325)
				}
			end,
			[2] = function()
				effectCodes = {
					{["op"] = 0x11, ["p1"] = function(sprite) return 3 * EEex_Sprite_GetLevels(sprite).base.highest end}, -- +3 HP per (base) character level
					{["op"] = 0x145, ["p1"] = 1} -- +1 to all saves (op325)
				}
			end,
			[3] = function()
				effectCodes = {
					{["op"] = 0x145, ["p1"] = 1}, -- +1 to all saves (op325)
					{["op"] = 0x116, ["p1"] = 1}, -- +1 to hit (op278)
					{["op"] = 0xA, ["p1"] = 1} -- +1 CON (op10)
				}
			end,
			[4] = function()
				effectCodes = {
					{["op"] = 0x145, ["p1"] = 1}, -- +1 to all saves (op325)
					{["op"] = 0x116, ["p1"] = 1}, -- +1 to hit (op278)
					{["op"] = 0xA, ["p1"] = 1} -- +1 CON (op10)
				}
			end,
			[5] = function()
				local randomPhysicalOp = EEex_Utility_PickRandom(physicalAttrTypes, 2)
				--
				effectCodes = {
					{["op"] = randomPhysicalOp[1], ["p1"] = 1}, -- +1 to a random physical attribute (CON, DEX, or STR)
					{["op"] = randomPhysicalOp[2], ["p1"] = 1} -- +1 to a random physical attribute (CON, DEX, or STR)
				}
			end,
			[6] = function()
				effectCodes = {
					{["op"] = 0x6, ["p1"] = 1}, -- +1 CHR (op6)
					{["op"] = 0xA, ["p1"] = 1}, -- +1 CON (op10)
					{["op"] = 0x145, ["p1"] = 1}, -- +1 to all saves (op325)
					{["op"] = 0x116, ["p1"] = 1} -- +1 to hit (op278)
				}
			end,
		}, function()
			EEex_Error("Should not happen")
		end)
	else
		EEex_Error(string.format("Invalid room type %d when reading global variable 'gtTweaksRevisedInnsRoomType'", roomType))
	end
	-- apply bonuses to party members (if any)
	if next(effectCodes) then
		-- add custom portrait icon
		if addPortraitIcon then
			table.insert(effectCodes,
				{["op"] = 0x8E, ["p2"] = %feedback_icon%} -- op142
			)
		end
		-- op321: prevent bonuses from stacking with themselves on subsequent inn rests
		table.insert(effectCodes, 1,
			{["op"] = 0x141, ["res"] = "GTRULE04"}
		)
		--
		for i = 0, 5 do
			local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
			if partyMember then -- sanity check
				for _, attributes in ipairs(effectCodes) do
					local p1 = attributes["p1"] or 0
					partyMember:applyEffect({
						["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
						["effectAmount"] = (type(p1) == "function") and p1(partyMember) or p1,
						["dwFlags"] = attributes["p2"] or 0,
						["duration"] = 4800, -- SIXTEEN_HOURS (as per gtimes.ids)
						["res"] = attributes["res"] or "",
						["m_sourceRes"] = "GTRULE04",
						["sourceID"] = partyMember.m_id,
						["sourceTarget"] = partyMember.m_id,
						["noSave"] = true, -- just in case...
					})
				end
			end
		end
	end
end

