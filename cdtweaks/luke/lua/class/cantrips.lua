--[[
+------------------------------------------------------------------------------------+
| cdtweaks, cantrips for spellcasters (wizards, clerics, druids, sorcerers, shamans) |
+------------------------------------------------------------------------------------+
--]]

-- compute the maximum # cantrips per day --

local function getMaxUsesPerDay(CGameSprite)
	local toReturn = 0
	--
	local tbl = {}
	local array = {}
	--
	local classLevels = CGameSprite:getLocalString("gtNWNCantripsClassLevels")
	local mxspl = CGameSprite:getLocalString("gtNWNCantripsMXSPL")
	--
	local m_level1 = CGameSprite.m_baseStats.m_level1
	local m_level2 = CGameSprite.m_baseStats.m_level2
	local m_level3 = CGameSprite.m_baseStats.m_level3
	--
	if string.find(classLevels, "_", 1, true) then
		local a, b = string.match(classLevels, "([1-3])_([1-3])")
		local x, y = string.match(mxspl, "([A-Z]+)_([A-Z]+)")
		--
		tbl[a] = x
		tbl[b] = y
	else
		tbl[classLevels] = mxspl
	end
	--
	for k, v in pairs(tbl) do
		local mxspl = GT_Resource_2DA["mxspl" .. string.lower(v)]
		if k == "1" then
			table.insert(array, tonumber(mxspl[tostring(m_level1)]["1"]))
		elseif k == "2" then
			table.insert(array, tonumber(mxspl[tostring(m_level2)]["1"]))
		elseif k == "3" then
			table.insert(array, tonumber(mxspl[tostring(m_level3)]["1"]))
		end
	end
	--
	toReturn = GT_Utility_FindGreatestInt(array)
	if toReturn > 1 then
		toReturn = toReturn - 1
	end
	--
	return toReturn
end

-- get caster type --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function(int, str1, str2)
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNCantripsCasterType", int)
		sprite:setLocalString("gtNWNCantripsMXSPL", str1)
		sprite:setLocalString("gtNWNCantripsClassLevels", str2)
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- single/multi/(complete)dual
	local isDruid = spriteClassStr == "DRUID"
	local isFighterDruid = spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x7) or spriteLevel1 > spriteLevel2)
	--
	local isCleric = spriteClassStr == "CLERIC"
	local isFighterCleric = spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel1 > spriteLevel2)
	local isClericThief = spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1)
	local isClericRanger = spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1)
	--
	local isMage = spriteClassStr == "MAGE"
	local isFighterMage = spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel1 > spriteLevel2)
	local isMageThief = spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel2 > spriteLevel1)
	--
	local isSorcerer = spriteClassStr == "SORCERER"
	--
	local isShaman = spriteClassStr == "SHAMAN"
	--
	local isFighterMageCleric = spriteClassStr == "FIGHTER_MAGE_CLERIC"
	local isFighterMageThief = spriteClassStr == "FIGHTER_MAGE_THIEF"
	--
	local isClericMage = spriteClassStr == "CLERIC_MAGE"
	--
	local casterType
	local classLevels
	local mxspl
	--
	if isDruid then
		casterType = 0x1
		classLevels = "1"
		mxspl = "DRU"
	elseif isFighterDruid then
		casterType = 0x1
		classLevels = "2"
		mxspl = "DRU"
	elseif isCleric or isClericThief or isClericRanger then
		casterType = 0x1
		classLevels = "1"
		mxspl = "PRS"
	elseif isFighterCleric then
		casterType = 0x1
		classLevels = "2"
		mxspl = "PRS"
	elseif isShaman then
		casterType = 0x1
		classLevels = "1"
		mxspl = "SHM"
	elseif isMage or isMageThief then
		casterType = 0x2
		classLevels = "1"
		mxspl = "WIZ"
	elseif isFighterMage or isFighterMageThief then
		casterType = 0x2
		classLevels = "2"
		mxspl = "WIZ"
	elseif isSorcerer then
		casterType = 0x2
		classLevels = "1"
		if spriteKitStr == "DRAGON_DISCIPLE" then
			mxspl = "DD"
		else
			mxspl = "SRC"
		end
	elseif isFighterMageCleric then
		classLevels = "2_3"
		mxspl = "WIZ_PRS"
		casterType = 0x3
	elseif isClericMage then
		if EEex_IsBitSet(spriteFlags, 0x4) then -- original class: mage
			if spriteLevel1 > spriteLevel2 then -- complete dual
				classLevels = "1_2"
				mxspl = "PRS_WIZ"
				casterType = 0x3
			else -- incomplete dual
				classLevels = "1"
				mxspl = "PRS"
				casterType = 0x1
			end
		elseif EEex_IsBitSet(spriteFlags, 0x5) then -- original class: cleric
			if spriteLevel2 > spriteLevel1 then -- complete dual
				classLevels = "1_2"
				mxspl = "PRS_WIZ"
				casterType = 0x3
			else -- incomplete dual
				classLevels = "2"
				mxspl = "WIZ"
				casterType = 0x2
			end
		else -- multiclass
			classLevels = "1_2"
			mxspl = "PRS_WIZ"
			casterType = 0x3
		end
	end
	--
	if sprite:getLocalInt("gtNWNCantripsCasterType") == 0 and sprite:getLocalString("gtNWNCantripsMXSPL") == "" and sprite:getLocalString("gtNWNCantripsClassLevels") == "" then
		if casterType and mxspl and classLevels then
			apply(casterType, mxspl, classLevels)
		end
	else
		if casterType and mxspl and classLevels then
			if casterType ~= sprite:getLocalInt("gtNWNCantripsCasterType") or mxspl ~= sprite:getLocalString("gtNWNCantripsMXSPL") or classLevels ~= sprite:getLocalString("gtNWNCantripsClassLevels") then
				apply(casterType, mxspl, classLevels)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNCantripsPerDay", 0)
			sprite:setLocalInt("gtNWNCantripsCasterType", 0x0)
			sprite:setLocalString("gtNWNCantripsMXSPL", "")
			sprite:setLocalString("gtNWNCantripsClassLevels", "")
		end
	end
end)

-- display a list of cantrips --

function GTCNTRP1(CGameEffect, CGameSprite)
	local array = EEex_Resource_Load2DA("GT#CNTRP")

	-- get caster type (bit0 -> priest, bit1 -> wizard)
	local casterType = CGameSprite:getLocalInt("gtNWNCantripsCasterType")

	-- get remaining uses per day
	local cantripsPerDay = CGameSprite:getLocalInt("gtNWNCantripsPerDay")

	-- alignment check
	local isGood = GT_Sprite_CheckIDS(CGameSprite, 0x1, 8) -- MASK_GOOD

	-- class check
	local mxspl = CGameSprite:getLocalString("gtNWNCantripsMXSPL")

	-- sanity check
	if cantripsPerDay > 0 then

		local savedCastType
		return EEex_Utility_MutateItr(
			EEex_Actionbar_GetOp214ButtonDataItr(CGameSprite:getValidSpellsWithAbilityItr(EEex_Utility_FilterItr(
				EEex_Utility_ApplyItr(array:getRowColumnsItr(nil, 0, 1), function(spellResRef, castType)
					savedCastType = castType
					return spellResRef
				end),
				function(spellResRef)
					local pHeader = EEex_Resource_Demand(spellResRef:upper(), "SPL")
					--
					local spellType = pHeader.itemType
					local spellcastingDisabled = GT_Sprite_SpellcastingDisabled(CGameSprite, spellType)
					--
					if pHeader.itemType == 2 and not spellcastingDisabled then -- priest
						if EEex_IsBitSet(casterType, 0x0) then
							if spellResRef:upper() ~= "%CLERIC_CAUSE_MINOR_WOUNDS%" or (not isGood and string.find(mxspl, "PRS", 1, true)) then -- evil clerics only
								if spellResRef:upper() ~= "%CLERIC_FLARE%" or (mxspl == "DRU" or mxspl == "SHM") then -- druids/shamans only
									if spellResRef:upper() ~= "%CLERIC_THORN_WHIP%" or (mxspl == "DRU" or mxspl == "SHM") then -- druids/shamans only
										if spellResRef:upper() ~= "%CLERIC_POISON_SPRAY%" or (mxspl == "DRU" or mxspl == "SHM") then -- druids/shamans only
											if spellResRef:upper() ~= "%CLERIC_BLADE_WARD%" or string.find(mxspl, "PRS", 1, true) then -- clerics only
												return true
											end
										end
									end
								end
							end
						end
					elseif pHeader.itemType == 1 and not spellcastingDisabled then -- wizard
						if EEex_IsBitSet(casterType, 0x1) then
							return true
						end
					end
				end
			))),
			function(buttonData)
				buttonData.m_abilityId.m_itemType = tonumber(savedCastType) or 3
				buttonData.m_bDisplayCount = true
				buttonData.m_count = cantripsPerDay
			end
		)

	end

end

-- you can access the cantrips submenu upon pressing the Right Alt key while being in Cast Spell mode (F7) --

EEex_Key_AddPressedListener(function(key)

	local sprite = EEex_Sprite_GetSelected()
	if not sprite then
		return
	end

	local lastState = EEex_Actionbar_GetLastState()
	local state = EEex_Actionbar_GetState()

	local cantripsPerDay = sprite:getLocalInt("gtNWNCantripsPerDay")

	local aux = EEex_GetUDAux(sprite)

	if cantripsPerDay > 0 then
		if sprite.m_typeAI.m_EnemyAlly == 2 then -- if [PC]
			if (lastState >= 1 and lastState <= 21) and (state == 103 or state == 113) then -- if Cast Spell menu
				if key == EEex_Key_GetFromName("Right Alt") then -- if the Right Alt key is pressed
					if EEex_Sprite_GetCastTimer(sprite) == -1 or sprite:getActiveStats().m_bAuraCleansing > 0 then -- aura check...
						sprite:applyEffect({
							["effectID"] = 214, -- Select spell
							["dwFlags"] = 3, -- from lua
							["res"] = "GTCNTRP1", -- lua func
							["noSave"] = true,
							["sourceID"] = sprite.m_id,
							["sourceTarget"] = sprite.m_id,
						})
						--
						aux["gt_NWN_Cantrips_Actionbar_LastState"] = lastState -- store it for later restoration
					end
				end
			end
		end
	end

end)

-- restore the previous actionbar state after starting an action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local aux = EEex_GetUDAux(sprite)

	if aux["gt_NWN_Cantrips_Actionbar_LastState"] then

		if EEex_UDEqual(sprite, EEex_Sprite_GetSelected()) then

			EEex_Actionbar_SetState(aux["gt_NWN_Cantrips_Actionbar_LastState"])

		end

		aux["gt_NWN_Cantrips_Actionbar_LastState"] = nil

	end
end)

-- prevent the Cast Spell (F7) button from greying out if the caster has no memorized spells (but can still cast cantrips!) --

EEex_Actionbar_AddButtonsUpdatedListener(function()

	local sprite = EEex_Sprite_GetSelected()
	if not sprite then
		return
	end

	local array = EEex_Actionbar_GetArray()
	local cantripsPerDay = sprite:getLocalInt("gtNWNCantripsPerDay")

	if cantripsPerDay > 0 then
		for i = 0, 11 do
			if array.m_buttonTypes:get(i) == EEex_Actionbar_ButtonType.CAST_SPELL then
				if array.m_buttonArray:getReference(i).m_bGreyOut == 1 then
					array.m_buttonArray:getReference(i).m_bGreyOut = 0
				end
				break
			end
		end
	end
end)

-- initial setup (f.i. new game) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- grant the actual uses per day
	if sprite:getLocalInt("gtNWNCantripsCasterType") > 0 and sprite:getLocalInt("gtNWNCantripsSetUp") == 0 then
		sprite:setLocalInt("gtNWNCantripsSetUp", 1)
		sprite:setLocalInt("gtNWNCantripsPerDay", getMaxUsesPerDay(sprite))
	end
end)

-- deal with spell deflection/reflection/trap --

function GTCNTRP2(CGameEffect, CGameSprite)

	local deflection = false
	local reflection = false
	local trap = false

	local func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				func(CGameEffectBase)
			end
		elseif effect.m_effectId == 102 or effect.m_effectId == 201 then -- Immunity to spell level / Spell deflection
			deflection = true
		elseif effect.m_effectId == 199 or effect.m_effectId == 200 then -- Reflect spell level / Spell turning
			reflection = true
		elseif effect.m_effectId == 259 then -- Spell trap
			trap = true
		end
	end

	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, func)
	if not deflection or not reflection or not trap then
		EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, func)
	end

	if CGameEffect.m_sourceId ~= CGameEffect.m_sourceTarget then

		if trap then
			if CGameSprite:getLocalInt("gtNWNCantripsCasterType") > 0 then -- sanity check
				local maxCantripsPerDay = getMaxUsesPerDay(CGameSprite)
				local currentCantripsPerDay = CGameSprite:getLocalInt("gtNWNCantripsPerDay")
				--
				if currentCantripsPerDay < maxCantripsPerDay then
					CGameSprite:setLocalInt("gtNWNCantripsPerDay", currentCantripsPerDay + 1)
				end
			end
			-- absorb spell
			CGameSprite:applyEffect({
				["effectID"] = 206, -- Protection from spell
				["effectAmount"] = -1, -- no feedback
				["res"] = CGameEffect.m_sourceRes:get(),
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end

		if reflection then
			-- reflect spell
			CGameSprite:applyEffect({
				["effectID"] = 207, -- Reflect specified spell
				["res"] = CGameEffect.m_sourceRes:get(),
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
			CGameSprite:applyEffect({
				["effectID"] = 206, -- Protection from spell
				["effectAmount"] = -1, -- no feedback
				["res"] = CGameEffect.m_sourceRes:get(),
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end

		if deflection then
			-- deflect spell
			CGameSprite:applyEffect({
				["effectID"] = 206, -- Protection from spell
				["effectAmount"] = -1, -- no feedback
				["res"] = CGameEffect.m_sourceRes:get(),
				["noSave"] = true,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end

	end

end

-- recharge var "gtNWNCantripsPerDay" upon resting --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)

	local actionSources = {
		[96] = true, -- Rest()
		[230] = true, -- RestParty()
		[243] = true, -- RestNoSpells()
	}

	if sprite:getLocalInt("gtNWNCantripsCasterType") > 0 then -- sanity check

		if actionSources[action.m_actionID] then

			sprite:setLocalInt("gtNWNCantripsPerDay", getMaxUsesPerDay(sprite))

		end

	end

end)

