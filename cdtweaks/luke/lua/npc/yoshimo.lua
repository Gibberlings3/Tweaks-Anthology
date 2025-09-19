--[[
+----------------------------------------------------------------------------------------------+
| cdtweaks, Yoshimo (https://www.gibberlings3.net/forums/topic/40019-a-special-tweak-request/) |
+----------------------------------------------------------------------------------------------+
--]]

-- Store Yoshimo's starting XP in a local variable when he first joins the party --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	if not EEex_GameObject_IsSprite(sprite) or sprite.m_scriptName:get() ~= "Yoshimo" then
		return
	end
	-- Make sure to take into account the script that adjustes XP so as to match the XP value of the Protagonist
	local adjustedXP = sprite:getLocalInt("BD_JOINXP") == 1
	-- Make sure Yoshimo is actually in the party
	local inParty = false
	for i = 0, 5 do
		local partyMember = EEex_Sprite_GetInPortrait(i)
		if partyMember and partyMember.m_scriptName:get() == sprite.m_scriptName:get() then
			inParty = true
			break
		end
	end
	--
	local protagonist = EEex_GameObject_Get(EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nProtagonistId)
	--
	if protagonist and protagonist:getLocalInt("gtYoshimoStartingXP") == 0 then
		if inParty and adjustedXP then
			protagonist:setLocalInt("gtYoshimoStartingXP", sprite.m_baseStats.m_xp)
		end
	end
end)

-- Make it so that you are getting back what he has "taken" from you --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	if not EEex_GameObject_IsSprite(sprite) or sprite.m_id ~= EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nProtagonistId then
		return
	end
	-- Make sure you are not in dialogue mode
	local inDialog = false
	for i = 0, 5 do
		local partyMember = EEex_Sprite_GetInPortrait(i)
		--
		if partyMember then
			--
			EEex_Utility_IterateCPtrList(partyMember.m_portraitIcons, function(portraitIcon)
				if portraitIcon.icon == 88 then
					inDialog = true
					return true
				end
			end)
			--
			if inDialog then
				break
			end
		end
	end
	-- Make sure you finished his questline
	local yoshimosHeart = EEex_GameState_GetGlobalInt("yoshimos_heart") == 1
	-- Get Yoshimo's XP (when he last left the party)
	local lastUpdateXP
	EEex_Utility_IterateCPtrList(EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_lstGlobalCreatures, function(id)
		local npc = EEex_GameObject_Get(id)
		if npc and npc.m_scriptName:get() == "Yoshimo" then
			lastUpdateXP = npc.m_baseStats.m_xp
			return true
		end
	end)
	--
	if sprite:getLocalInt("gtYoshimoGaveBackXP") == 0 then
		if not inDialog and yoshimosHeart and lastUpdateXP then
			-- update var
			sprite:setLocalInt("gtYoshimoGaveBackXP", 1)
			-- sanity check
			local deltaXP = lastUpdateXP - sprite:getLocalInt("gtYoshimoStartingXP")
			if deltaXP > 0 then
				-- give back the XP
				local str = string.format("AddexperienceParty(%d)", deltaXP)
				GT_ExecuteResponse["parseResponseString"](sprite, nil, str)
				-- feedback string
				sprite:applyEffect({
					["effectID"] = 0x14A, -- Float text (330)
					["effectAmount"] = %feedback_strref%,
					["noSave"] = true,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

