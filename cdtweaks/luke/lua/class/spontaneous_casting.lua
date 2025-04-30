--[[
+----------------------------------------+
| cdtweaks, spontaneous cast for clerics |
+----------------------------------------+
--]]

-- clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

function %PRIEST_SPONTANEOUS_CAST%(CGameEffect, CGameSprite)
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

-- clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

EEex_Key_AddPressedListener(function(key)
	local sprite = EEex_Sprite_GetSelected()
	if not sprite then
		return
	end
	-- check for op145
	local found = GT_Utility_Sprite_CheckForEffect(sprite, {["op"] = 0x91, ["p2"] = 1}) or GT_Utility_Sprite_CheckForEffect(sprite, {["op"] = 0x91, ["p2"] = 3})
	--
	local lastState = EEex_Actionbar_GetLastState()
	-- Check creature's class / flags / alignment
	local isEvil = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_EVIL)")
	local isGood = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_GOOD)")
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	local spriteFlags = sprite.m_baseStats.m_flags
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- single/multi/(complete)dual
	local canSpontaneouslyCast = spriteClassStr == "CLERIC" or spriteClassStr == "FIGHTER_MAGE_CLERIC"
		or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "CLERIC_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
	--
	if not found then
		if canSpontaneouslyCast then
			if (lastState >= 1 and lastState <= 21) and EEex_Sprite_GetCastTimer(sprite) == -1 and sprite.m_typeAI.m_EnemyAlly == 2 and key == 0x400000E2 and (EEex_Actionbar_GetState() == 103 or EEex_Actionbar_GetState() == 113) then -- if PC, the Left Alt key is pressed, and the aura is free ...
				if isGood:evalConditionalAsAIBase(sprite) then
					--
					local effectCodes = {
						{["op"] = 321, ["res"] = "%PRIEST_SPONTANEOUS_CAST%"}, -- remove effects by resource
						{["op"] = 232, ["p2"] = 16, ["res"] = "%PRIEST_SPONTANEOUS_CAST%B"}, -- cast spl on condition (condition: Die(); target: self)
						{["op"] = 214, ["p1"] = 1, ["p2"] = 3, ["res"] = "%PRIEST_SPONTANEOUS_CAST%"}, -- select spell
					}
					--
					for _, attributes in ipairs(effectCodes) do
						sprite:applyEffect({
							["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
							["effectAmount"] = attributes["p1"] or 0,
							["dwFlags"] = attributes["p2"] or 0,
							["res"] = attributes["res"] or "",
							["durationType"] = 1,
							["m_sourceRes"] = "%PRIEST_SPONTANEOUS_CAST%",
							["sourceID"] = sprite.m_id,
							["sourceTarget"] = sprite.m_id,
						})
					end
					--
					sprite:setLocalInt("gtSpontaneousCastActionbar", lastState) -- store it for later restoration
				elseif isEvil:evalConditionalAsAIBase(sprite) then
					--
					local effectCodes = {
						{["op"] = 321, ["res"] = "%PRIEST_SPONTANEOUS_CAST%"}, -- remove effects by resource
						{["op"] = 232, ["p2"] = 16, ["res"] = "%PRIEST_SPONTANEOUS_CAST%B"}, -- cast spl on condition (condition: Die(); target: self)
						{["op"] = 214, ["p1"] = 2, ["p2"] = 3, ["res"] = "%PRIEST_SPONTANEOUS_CAST%"}, -- select spell
					}
					--
					for _, attributes in ipairs(effectCodes) do
						sprite:applyEffect({
							["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
							["effectAmount"] = attributes["p1"] or 0,
							["dwFlags"] = attributes["p2"] or 0,
							["res"] = attributes["res"] or "",
							["durationType"] = 1,
							["m_sourceRes"] = "%PRIEST_SPONTANEOUS_CAST%",
							["sourceID"] = sprite.m_id,
							["sourceTarget"] = sprite.m_id,
						})
					end
					--
					sprite:setLocalInt("gtSpontaneousCastActionbar", lastState) -- store it for later restoration
				end
			end
		end
	end
	--
	isGood:free()
	isEvil:free()
end)

-- check if the caster has at least 1 spell of appropriate level memorized (f.i. at least 1 spell of level 1 if it intends to spontaneously cast Cure/Cause Light Wounds). If so, decrement (unmemorize) all spells of that level by 1 --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("gtSpontaneousCastActionbar") > 0 then
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
		EEex_Actionbar_SetState(sprite:getLocalInt("gtSpontaneousCastActionbar"))
		--
		sprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["dwFlags"] = 1, -- instant/ignore level
			["res"] = "%PRIEST_SPONTANEOUS_CAST%B",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
end)

-- reset var to 0 if the caster dies while being in "Cast Spell" mode (F7) / after starting an action --

function %PRIEST_SPONTANEOUS_CAST%B(CGameEffect, CGameSprite)
	CGameSprite:applyEffect({
		["effectID"] = 321, -- Remove effects by resource
		["res"] = "%PRIEST_SPONTANEOUS_CAST%",
		["sourceID"] = CGameSprite.m_id,
		["sourceTarget"] = CGameSprite.m_id,
	})
	--
	CGameSprite:setLocalInt("gtSpontaneousCastActionbar", 0)
end
