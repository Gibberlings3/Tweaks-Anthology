-- cdtweaks, spontaneous cast for clerics: clerics can spontaneously cast Cure/Cause Wounds spells upon pressing the Left Alt key when in "Cast Spell" mode (F7) --

EEex_Key_AddPressedListener(function(key)
	local sprite = EEex_Sprite_GetSelected()
	if not sprite then
		return
	end
	-- cannot be used in conjunction with the Metamagic feat
	local metamagicRes = {"CDMTMQCK", "CDMTMEMP", "CDMTMEXT", "CDMTMMAX", "CDMTMSIL", "CDMTMSTL"}
	for _, v in ipairs(metamagicRes) do
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = v,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- check for op145
	local found = false
	local disableSpellcasting = function(effect)
		if (effect.m_effectId == 0x91) and (effect.m_dWFlags == 1 or effect.m_dWFlags == 3) then
			found = true
			return true
		end
	end
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, disableSpellcasting)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, disableSpellcasting)
	end
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
					sprite:applyEffect({
						["effectID"] = 214, -- Select spell
						["durationType"] = 1,
						["effectAmount"] = 1,
						["dwFlags"] = 3,
						["res"] = "GTSPCAST", -- lua function
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
					sprite:setLocalInt("cdtweaksSpontaneousCast", lastState) -- store it for later restoration
				elseif isEvil:evalConditionalAsAIBase(sprite) then
					sprite:applyEffect({
						["effectID"] = 214, -- Select spell
						["durationType"] = 1,
						["effectAmount"] = 2,
						["dwFlags"] = 3,
						["res"] = "GTSPCAST", -- lua function
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
					sprite:setLocalInt("cdtweaksSpontaneousCast", lastState) -- store it for later restoration
				end
			end
		end
	end
	--
	isGood:free()
	isEvil:free()
end)

-- cdtweaks, spontaneous cast for clerics: check if the caster has at least 1 spell of appropriate level memorized (f.i. at least 1 spell of level 1 if it intends to spontaneously cast Cure/Cause Light Wounds). If so, decrement (unmemorize) all spells of that level by 1

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksSpontaneousCast") > 0 then
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
					["durationType"] = 1,
					["effectAmount"] = feedbackStrRefs[spellLevel],
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				-- abort action
				action.m_actionID = 0 -- NoAction()
			end
		end
		--
		EEex_Actionbar_SetState(sprite:getLocalInt("cdtweaksSpontaneousCast"))
		sprite:setLocalInt("cdtweaksSpontaneousCast", 0)
	end
end)
