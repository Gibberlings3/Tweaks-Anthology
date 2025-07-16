--[[
+------------------------------------------------------------+
| cdtweaks, NWN-ish Knockdown ability for Fighters and Monks |
+------------------------------------------------------------+
--]]

-- NWN-ish Knockdown ability (main) --

function %INNATE_KNOCKDOWN%(CGameEffect, CGameSprite)
	-- Creatures already on the ground / levitating / etc. should be immune to this feat --
	local naturalImmunity = {
		{"WEAPON"}, -- GENERAL.IDS
		{"DRAGON", "BEHOLDER", "ANKHEG", "SLIME", "DEMILICH", "WILL-O-WISP", "SPECTRAL_UNDEAD", "SHADOW", "SPECTRE", "WRAITH", "MIST", "GENIE", "ELEMENTAL", "SALAMANDER"}, -- RACE.IDS
		{"WIZARD_EYE", "SPECTRAL_TROLL", "SPIDER_WRAITH"}, -- CLASS.IDS
		-- ANIMATE.IDS
		{
			"DOOM_GUARD", "DOOM_GUARD_LARGER", -- 0x6000
			"SNAKE", "BLOB_MIST_CREATURE", "MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER", "DANCING_SWORD", -- 0x7000
			"SHADOW_SMALL", "SHADOW_LARGE", "WATER_WEIRD" -- 0xE000
		},
	}
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	-- Get personal space
	local sourcePersonalSpace = EEex_Sprite_GetPersonalSpace(sourceSprite)
	local targetPersonalSpace = EEex_Sprite_GetPersonalSpace(CGameSprite)
	--
	local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local targetClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
	local targetAnimateStr = GT_Resource_IDSToSymbol["animate"][CGameSprite.m_animation.m_animation.m_animationID]
	--
	local targetIDS = {targetGeneralStr, targetRaceStr, targetClassStr, targetAnimateStr}
	-- MAIN --
	-- immunity check
	local found = false
	do
		for index, symbolList in ipairs(naturalImmunity) do
			for _, symbol in ipairs(symbolList) do
				if targetIDS[index] == symbol then
					found = true
					goto found
				end
			end
		end
	end
	--
	::found::
	if not found then
		if (sourcePersonalSpace - targetPersonalSpace) >= -1 then
			-- Fetch components of check
			local roll = Infinity_RandomNumber(1, 20) -- 1d20
			--
			local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
			--
			local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
			--
			local creatureSizeModifier = 0
			if (sourcePersonalSpace - targetPersonalSpace) > 0 then
				creatureSizeModifier = 4
			elseif (sourcePersonalSpace - targetPersonalSpace) < 0 then
				creatureSizeModifier = -4
			end
			--
			local thac0 = sourceActiveStats.m_nTHAC0 -- base thac0 (STAT 7)
			local luck = sourceActiveStats.m_nLuck -- STAT 32
			local thac0BonusRight = sourceActiveStats.m_THAC0BonusRight -- this should include the bonus from the weapon + str + wspecial.2da + op288 (STAT 170) + op284 (STAT 166) + stylbonu.2da
			--local meleeTHAC0Bonus = sourceActiveStats.m_nMeleeTHAC0Bonus -- op284 (STAT 166)
			--local fistTHAC0Bonus = sourceActiveStats.m_nFistTHAC0Bonus -- op288 (STAT 170)
			-- op178
			local thac0VsTypeBonus = GT_Sprite_Thac0VsTypeBonus(sourceSprite, CGameSprite)
			-- op219
			local attackRollPenalty = GT_Sprite_AttackRollPenalty(sourceSprite, CGameSprite)
			-- racial enemy
			local racialEnemy = GT_Sprite_GetRacialEnemyBonus(sourceSprite, CGameSprite)
			-- attack of opportunity
			local attackOfOpportunity = GT_Sprite_GetAttackOfOpportunityBonus(sourceSprite, CGameSprite)
			-- invisibility
			local strikingFromInvisibility = GT_Sprite_StrikingFromInvisibilityBonus(sourceSprite, CGameSprite)
			local invisibleTarget = GT_Sprite_InvisibleTargetPenalty(sourceSprite, CGameSprite)
			-- op120
			local conditionalString = 'WeaponEffectiveVs(EEex_Target("gtScriptingTarget"),MAINHAND)'
			-- mainhand weapon
			local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
			--
			local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
			--
			if GT_Trigger_EvalConditional["parseConditionalString"](sourceSprite, CGameSprite, conditionalString) then
				-- compute attack roll (am I missing something...?)
				local success = false
				local modifier = luck + thac0BonusRight + thac0VsTypeBonus - attackRollPenalty + racialEnemy + attackOfOpportunity + strikingFromInvisibility - invisibleTarget + creatureSizeModifier - 4
				--
				local criticalHitMod, criticalMissMod = GT_Sprite_GetCriticalModifiers(sourceSprite)
				--
				local m_nTimeStopCaster = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nTimeStopCaster
				--
				if (roll >= 20 - criticalHitMod) or EEex_IsBitSet(targetActiveStats.m_generalState, 0x5) or m_nTimeStopCaster == sourceSprite.m_id then -- automatic hit
					success = true
					modifier = 0
				elseif roll <= 1 + criticalMissMod then -- automatic miss (critical failure)
					modifier = 0
				elseif roll + modifier >= thac0 - (targetActiveStats.m_nArmorClass + ACModifier) then
					success = true
				end
				--
				if success then
					-- display feedback message
					GT_Sprite_DisplayMessage(sourceSprite,
						string.format("%s : %d + %d = %d : %s",
							Infinity_FetchString(%feedback_strref_knockdown%), roll, modifier, roll + modifier, Infinity_FetchString(%feedback_strref_hit%)),
						0xBED7D7
					)
					--
					local effectCodes = {
						{["op"] = 39, ["p2"] = 1, ["spec"] = %feedback_icon%}, -- sleep (do not wake upon taking damage)
						{["op"] = 206, ["res"] = "%INNATE_KNOCKDOWN%B", ["p1"] = %feedback_strref_already_prone%}, -- protection from spell
					}
					--
					for _, attributes in ipairs(effectCodes) do
						CGameSprite:applyEffect({
							["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
							["effectAmount"] = attributes["p1"] or 0,
							["dwFlags"] = attributes["p2"] or 0,
							["duration"] = 6,
							["savingThrow"] = 0x800000, -- bypass op101 (in case of op39)
							["m_sourceRes"] = "%INNATE_KNOCKDOWN%B",
							["m_sourceType"] = 1,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				else
					-- display feedback message
					GT_Sprite_DisplayMessage(sourceSprite,
						string.format("%s : %d + %d = %d : %s",
							Infinity_FetchString(%feedback_strref_knockdown%), roll, modifier, roll + modifier, Infinity_FetchString(%feedback_strref_miss%)),
						0xBED7D7
					)
				end
			else
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 139, -- Display string
					["effectAmount"] = %feedback_strref_weapon_ineffective%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		else
			CGameSprite:applyEffect({
				["effectID"] = 139, -- display string
				["effectAmount"] = %feedback_strref_too_large%,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	else
		CGameSprite:applyEffect({
			["effectID"] = 139, -- immunity to resource and message
			["effectAmount"] = %feedback_strref_cannot_be_knocked_down%,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end

-- Make it castable at will. Prevent spell disruption. Check if melee weapon equipped --

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)
	local curAction = sprite.m_curAction
	local spriteAux = EEex_GetUDAux(sprite)

	if not (curAction.m_actionID == 31 and resref == "%INNATE_KNOCKDOWN%" and changeAmount < 0) then
		return
	end

	-- recast as ``ForceSpell()`` (so as to prevent spell disruption)
	curAction.m_actionID = 113

	local spellHeader = EEex_Resource_Demand(resref, "SPL")
	local spellLevelMemListArray = sprite.m_memorizedSpellsInnate
	local memList = spellLevelMemListArray:getReference(spellHeader.spellLevel - 1) -- !!!count starts from 0!!!

	-- restore memorization bit
	EEex_Utility_IterateCPtrList(memList, function(memInstance)
		local memInstanceResref = memInstance.m_spellId:get()
		if memInstanceResref == resref then
			local memFlags = memInstance.m_flags
			if EEex_IsBitUnset(memFlags, 0x0) then
				memInstance.m_flags = EEex_SetBit(memFlags, 0x0)
			end
		end
	end)

	-- make sure the creature is equipped with a melee weapon
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	if selectedWeapon["ability"].type == 1 then
		-- store target id
		spriteAux["gt_NWN_Knockdown_TargetID"] = curAction.m_acteeID.m_Instance
		-- initialize the attack frame counter
		sprite.m_attackFrame = 0
	else
		sprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_melee_only%,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end

end)

-- Cast the "actual" spl (ability) when the attack frame counter is 6 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	--
	if sprite:getLocalInt("gtNWNKnockdown") == 1 then
		if selectedWeapon["ability"].type == 1 then -- melee weapon
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gt_NWN_Knockdown_TargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gt_NWN_Knockdown_TargetID"])
					spriteAux["gt_NWN_Knockdown_TargetID"] = nil
					--
					targetSprite:applyEffect({
						["effectID"] = 138, -- set animation
						["dwFlags"] = 4, -- SEQ_DAMAGE
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
					targetSprite:applyEffect({
						["effectID"] = 402, -- invoke lua
						["res"] = "%INNATE_KNOCKDOWN%",
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
				end
			end
		end
	end
end)

-- Forget about ``spriteAux["gt_Aux_NWN_Knockdown_TargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtNWNKnockdown") == 1 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%INNATE_KNOCKDOWN%") then
			if spriteAux["gt_NWN_Knockdown_TargetID"] ~= nil then
				spriteAux["gt_NWN_Knockdown_TargetID"] = nil
			end
		end
	end
end)

-- cdtweaks, NWN-ish Knockdown ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or Infinity_GetCurrentScreenName() == 'CHARGEN' then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNKnockdown", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
				["res"] = "%INNATE_KNOCKDOWN%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local isFighterAll = GT_Sprite_CheckIDS(sprite, class["FIGHTER_ALL"], 5)
	--
	local gainAbility = isFighterAll
	--
	if sprite:getLocalInt("gtNWNKnockdown") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNKnockdown", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%INNATE_KNOCKDOWN%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

