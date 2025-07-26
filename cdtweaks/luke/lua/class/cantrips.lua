--[[
+------------------------------------------------------------------------------------+
| cdtweaks, cantrips for spellcasters (wizards, clerics, druids, sorcerers, shamans) |
+------------------------------------------------------------------------------------+
--]]

-- get caster type, class levels, mxspl### --

local function getCasterType(CGameSprite)
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
	--
	local spriteFlags = CGameSprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(CGameSprite.m_derivedStats.m_nKit)
	local spriteLevel1 = CGameSprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = CGameSprite.m_derivedStats.m_nLevel2
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
	if isDruid then
		return "1", "DRU"
	elseif isFighterDruid then
		return "2", "DRU"
	elseif isCleric or isClericThief or isClericRanger then
		return "1", "PRS"
	elseif isFighterCleric then
		return "2", "PRS"
	elseif isShaman then
		return "1", "SHM"
	elseif isMage or isMageThief then
		return "1", "WIZ"
	elseif isFighterMage or isFighterMageThief then
		return "2", "WIZ"
	elseif isSorcerer then
		if spriteKitStr == "DRAGON_DISCIPLE" then
			return "1", "DD"
		else
			return "1", "SRC"
		end
	elseif isFighterMageCleric then
		return "2_3", "WIZ_PRS"
	elseif isClericMage then
		if EEex_IsBitSet(spriteFlags, 0x4) then -- original class: mage
			if spriteLevel1 > spriteLevel2 then -- complete dual
				return "1_2", "PRS_WIZ"
			else -- incomplete dual
				return "1", "PRS"
			end
		elseif EEex_IsBitSet(spriteFlags, 0x5) then -- original class: cleric
			if spriteLevel2 > spriteLevel1 then -- complete dual
				return "1_2", "PRS_WIZ"
			else -- incomplete dual
				return "2", "WIZ"
			end
		else -- multiclass
			return "1_2", "PRS_WIZ"
		end
	end
	-- default case
	return nil, nil
end

-- compute the maximum # cantrips castable per day --

local function getMaxUsesPerDay(CGameSprite, classLevels, mxspl)
	local toReturn = 0
	--
	if classLevels and mxspl then
		local tbl = {}
		local array = {}
		--
		local m_nLevel1 = CGameSprite.m_derivedStats.m_nLevel1
		local m_nLevel2 = CGameSprite.m_derivedStats.m_nLevel2
		local m_nLevel3 = CGameSprite.m_derivedStats.m_nLevel3
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
			local temp = GT_Resource_2DA["mxspl" .. string.lower(v)]
			if k == "1" then
				table.insert(array, tonumber(temp[tostring(m_nLevel1)]["1"]))
			elseif k == "2" then
				table.insert(array, tonumber(temp[tostring(m_nLevel2)]["1"]))
			elseif k == "3" then
				table.insert(array, tonumber(temp[tostring(m_nLevel3)]["1"]))
			end
		end
		--
		toReturn = GT_Utility_FindGreatestInt(array)
		if toReturn > 1 then
			toReturn = toReturn - 1
		end
	end
	--
	return toReturn
end

-- apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function(mxspl, maxCantripsPerDay)
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNMaxCantripsPerDay", maxCantripsPerDay)
		sprite:setLocalString("gtNWNCantripsMXSPL", mxspl)
	end
	-- Check creature's class / flags
	local classLevels, mxspl = getCasterType(sprite)
	local maxCantripsPerDay = getMaxUsesPerDay(sprite, classLevels, mxspl)
	--
	local applyAbility = mxspl and maxCantripsPerDay > 0
	--
	if sprite:getLocalInt("gtNWNMaxCantripsPerDay") == 0 and sprite:getLocalString("gtNWNCantripsMXSPL") == "" then
		if applyAbility then
			apply(mxspl, maxCantripsPerDay)
		end
	else
		if applyAbility then
			if maxCantripsPerDay ~= sprite:getLocalInt("gtNWNMaxCantripsPerDay") or mxspl ~= sprite:getLocalString("gtNWNCantripsMXSPL") then
				apply(mxspl, maxCantripsPerDay)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNMaxCantripsPerDay", 0)
			sprite:setLocalInt("gtNWNCurCantripsPerDay", 0)
			sprite:setLocalString("gtNWNCantripsMXSPL", "")
		end
	end
end)

-- display a list of cantrips --

function GTCNTRP1(CGameEffect, CGameSprite)
	local array = EEex_Resource_Load2DA("GT#CNTRP")
	local align = GT_Resource_SymbolToIDS["align"]

	-- get max / cur uses per day
	local maxCantripsPerDay = CGameSprite:getLocalInt("gtNWNMaxCantripsPerDay")
	local curCantripsPerDay = CGameSprite:getLocalInt("gtNWNCurCantripsPerDay")

	-- get caster type
	local mxspl = CGameSprite:getLocalString("gtNWNCantripsMXSPL")

	-- sanity check
	if curCantripsPerDay < maxCantripsPerDay then

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
					local exclusionFlags = pHeader.notUsableBy
					--
					if spellType == 2 and not spellcastingDisabled then -- priest
						if string.find(mxspl, "PRS", 1, true) or (mxspl == "DRU" or mxspl == "SHM") then
							-- alignment check
							if EEex_IsBitUnset(exclusionFlags, 0x0) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_CHAOTIC"], 8) then
								if EEex_IsBitUnset(exclusionFlags, 0x1) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_EVIL"], 8) then
									if EEex_IsBitUnset(exclusionFlags, 0x2) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_GOOD"], 8) then
										if EEex_IsBitUnset(exclusionFlags, 0x3) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_LCNEUTRAL"], 8) then
											if EEex_IsBitUnset(exclusionFlags, 0x4) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_LAWFUL"], 8) then
												if EEex_IsBitUnset(exclusionFlags, 0x5) or not GT_Sprite_CheckIDS(CGameSprite, align["MASK_GENEUTRAL"], 8) then
													-- class check
													if EEex_IsBitUnset(exclusionFlags, 30) or not string.find(mxspl, "PRS", 1, true) then
														if EEex_IsBitUnset(exclusionFlags, 31) or not (mxspl == "DRU" or mxspl == "SHM") then
															return true
														end
													end
												end
											end
										end
									end
								end
							end
						end
					elseif spellType == 1 and not spellcastingDisabled then -- wizard
						if string.find(mxspl, "WIZ", 1, true) or (mxspl == "SRC" or mxspl == "DD") then
							return true
						end
					end
				end
			))),
			function(buttonData)
				buttonData.m_abilityId.m_itemType = tonumber(savedCastType) or 3
				buttonData.m_bDisplayCount = true
				buttonData.m_count = maxCantripsPerDay - curCantripsPerDay
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

	local maxCantripsPerDay = sprite:getLocalInt("gtNWNMaxCantripsPerDay")

	local aux = EEex_GetUDAux(sprite)

	if maxCantripsPerDay > 0 then
		if sprite.m_typeAI.m_EnemyAlly == 2 then -- if [PC]
			if (lastState >= 1 and lastState <= 21) and (state == 103 or state == 113) then -- if Cast Spell menu
				if key == EEex_Key_GetFromName("Right Alt") then -- if the Right Alt key is pressed
					if EEex_Sprite_GetCastTimer(sprite) == -1 or sprite:getActiveStats().m_bAuraCleansing > 0 then -- aura check...
						sprite:applyEffect({
							["effectID"] = 214, -- Select spell
							["dwFlags"] = 3, -- from lua
							["res"] = "GTCNTRP1", -- lua func
							["durationType"] = 1,
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
	local maxCantripsPerDay = sprite:getLocalInt("gtNWNMaxCantripsPerDay")
	local curCantripsPerDay = sprite:getLocalInt("gtNWNCurCantripsPerDay")

	if curCantripsPerDay < maxCantripsPerDay then
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

-- deal with spell deflection/reflection/trap --

function GTCNTRP2(CGameEffect, CGameSprite)

	local deflection = false
	local reflection = false
	local trap = false

	local func
	func = function(effect)
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

	local maxCantripsPerDay = CGameSprite:getLocalInt("gtNWNMaxCantripsPerDay")
	local curCantripsPerDay = CGameSprite:getLocalInt("gtNWNCurCantripsPerDay")

	if CGameEffect.m_sourceId ~= CGameEffect.m_sourceTarget then

		if trap then
			if maxCantripsPerDay > 0 then -- sanity check
				if curCantripsPerDay > 0 then
					CGameSprite:setLocalInt("gtNWNCurCantripsPerDay", curCantripsPerDay - 1)
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

-- recharge var "gtNWNCurCantripsPerDay" upon resting --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)

	local actionSources = {
		[96] = true, -- Rest()
		[230] = true, -- RestParty()
		[243] = true, -- RestNoSpells()
	}

	if sprite:getLocalInt("gtNWNMaxCantripsPerDay") > 0 then -- sanity check

		if actionSources[action.m_actionID] then

			sprite:setLocalInt("gtNWNCurCantripsPerDay", 0)

		end

	end

end)

