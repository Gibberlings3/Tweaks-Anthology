--[[
+------------------------------------------------------------------------+
| cdtweaks, NWN-ish Dirty Fighting class feat for chaotic-aligned rogues |
+------------------------------------------------------------------------+
--]]

-- Apply Ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNDirtyFighting", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%THIEF_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["durationType"] = 9,
			["res"] = "%THIEF_DIRTY_FIGHTING%B", -- EFF file
			["m_sourceRes"] = "%THIEF_DIRTY_FIGHTING%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local class = GT_Resource_SymbolToIDS["class"]
	local align = GT_Resource_SymbolToIDS["align"]
	-- Check if rogue class -- single/multi/(complete)dual
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	-- Check if chaotic
	local isChaotic = GT_Sprite_CheckIDS(sprite, align["MASK_CHAOTIC"], 8)
	--
	local applyAbility = isThiefAll and isChaotic
	--
	if sprite:getLocalInt("gtNWNDirtyFighting") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNDirtyFighting", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%THIEF_DIRTY_FIGHTING%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core op402 listener --

function %THIEF_DIRTY_FIGHTING%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	local sourceAux = EEex_GetUDAux(sourceSprite)
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	--
	local isUsableBySingleClassThief = EEex_IsBitUnset(selectedWeapon["header"].notUsableBy, 22)
	--
	if sourceSprite.m_leftAttack == 1 then -- if off-hand attack
		local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
		local offHand = items:get(9) -- CItem
		--
		if offHand then -- sanity check
			local pHeader = offHand.pRes.pHeader -- Item_Header_st
			--
			if EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType) ~= "SHIELD" then -- if not shield, then overwrite item ability/usability check...
				selectedWeapon["ability"] = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
				isUsableBySingleClassThief = EEex_IsBitUnset(pHeader.notUsableBy, 22)
			end
		end
	end
	--
	local conditionalString = "EEex_IsImmuneToOpcode(Myself,12)"
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local resistDamageTypeTable = {
		[0x10] = targetActiveStats.m_nResistPiercing, -- piercing
		[0x0] = targetActiveStats.m_nResistCrushing, -- crushing
		[0x100] = targetActiveStats.m_nResistSlashing, -- slashing
		[0x80] = targetActiveStats.m_nResistMissile, -- missile
		[0x800] = targetActiveStats.m_nResistCrushing, -- non-lethal
	}
	--
	local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
	--
	if sourceAux["gt_NWN_DirtyFighting_FirstAttack"] then
		if isUsableBySingleClassThief then
			if resistDamageTypeTable[damageTypeIDS] < 100 and not GT_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, conditionalString) then
				-- 5% unmitigated damage
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 0xC, -- Damage
					["dwFlags"] = damageTypeIDS * 0x10000 + 3, -- mode: reduce by percentage
					--["numDice"] = 1,
					--["diceSize"] = 4,
					["effectAmount"] = 5,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				-- the percentage mode of op12 does not provide feedback, so we have to manually display it...
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Display string
					["effectAmount"] = %feedback_strref_hit%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			else
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Immunity to resource and message
					["effectAmount"] = %feedback_strref_immune%,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
end

-- Flag first attack in each round --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtNWNDirtyFightingTimer" then -- dummy opcode that acts as a marker/timer
			found = true
			return true
		end
	end)
	--local conditionalString = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("gtDirtyFightingTimer","LOCALS")')
	--local responseString = EEex_Action_ParseResponseString('SetGlobalTimer("gtDirtyFightingTimer","LOCALS",6)')
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtNWNDirtyFighting") == 1 then
		if sprite.m_startedSwing == 1 then
			if not found then
				-- set timer
				sprite:applyEffect({
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_DUMMY_STAT"],
					["noSave"] = true,
					["m_scriptName"] = "gtNWNDirtyFightingTimer",
					["duration"] = 90,
					["durationType"] = 10, -- instant/limited (ticks)
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				--
				spriteAux["gt_NWN_DirtyFighting_FirstAttack"] = true
			end
		else
			if found and spriteAux["gt_NWN_DirtyFighting_FirstAttack"] then
				spriteAux["gt_NWN_DirtyFighting_FirstAttack"] = false
			end
		end
	end
	--
	--conditionalString:free()
	--responseString:free()
end)

