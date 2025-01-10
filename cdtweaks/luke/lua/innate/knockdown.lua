--[[
+------------------------------------------------------------+
| cdtweaks, NWN-ish Knockdown ability for Fighters and Monks |
+------------------------------------------------------------+
--]]

-- NWN-ish Knockdown ability. Creatures already on the ground / levitating / etc. should be immune to this feat --

local cdtweaks_ImmuneToKnockdown = {
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

-- NWN-ish Knockdown ability (main) --

function %INNATE_KNOCKDOWN%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	-- Get personal space
	local sourcePersonalSpace = sourceSprite.m_animation.m_animation.m_personalSpace
	local targetPersonalSpace = CGameSprite.m_animation.m_animation.m_personalSpace
	--
	local class = GT_Resource_SymbolToIDS["class"]
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
		for index, symbolList in ipairs(cdtweaks_ImmuneToKnockdown) do
			for _, symbol in ipairs(symbolList) do
				if targetIDS[index] == symbol then
					found = true
					break
				end
			end
		end
	end
	--
	if not found then
		if (sourcePersonalSpace - targetPersonalSpace) >= -1 then
			-- set ``savebonus``
			local savebonus = 0
			if (sourcePersonalSpace - targetPersonalSpace) > 0 then
				savebonus = -4
			elseif (sourcePersonalSpace - targetPersonalSpace) < 0 then
				savebonus = 4
			end
			--
			local effectCodes = {
				{["op"] = 39, ["p2"] = 1, ["spec"] = %feedback_icon%, ["stype"] = EEex_BOr(0x800000, 0x4)}, -- sleep (do not wake upon taking damage)
				{["op"] = 206, ["res"] = "%INNATE_KNOCKDOWN%B", ["p1"] = %feedback_strref_already_prone%, ["stype"] = 0x4}, -- protection from spell
			}
			--
			for _, attributes in ipairs(effectCodes) do
				CGameSprite:applyEffect({
					["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
					["effectAmount"] = attributes["p1"] or 0,
					["dwFlags"] = attributes["p2"] or 0,
					["duration"] = 6,
					["savingThrow"] = attributes["stype"] or 0, -- save vs. death / bypass op101 (in case of op39)
					["saveMod"] = savebonus,
					["m_sourceRes"] = "%INNATE_KNOCKDOWN%B",
					["m_sourceType"] = 1,
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

	-- nuke current action
	curAction.m_actionID = 0

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
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	if not isWeaponRanged:evalConditionalAsAIBase(sprite) then
		-- store target id
		spriteAux["gtKnockdownTargetID"] = curAction.m_acteeID.m_Instance
		-- initialize the attack frame counter
		sprite.m_attackFrame = 0
		-- recast the ability as "ForceSpell()"
		local targetSprite = EEex_GameObject_Get(curAction.m_acteeID.m_Instance)
		targetSprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["res"] = resref,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = targetSprite.m_id,
		})
	else
		sprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_melee_only%,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end

	isWeaponRanged:free()
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
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("gtInnateKnockdown") == 1 then
		if not isWeaponRanged:evalConditionalAsAIBase(sprite) then
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gtKnockdownTargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gtKnockdownTargetID"])
					spriteAux["gtKnockdownTargetID"] = nil
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
	--
	isWeaponRanged:free()
end)

-- Forget about ``spriteAux["gtKnockdownTargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtInnateKnockdown") == 1 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%INNATE_KNOCKDOWN%") then
			if spriteAux["gtKnockdownTargetID"] ~= nil then
				spriteAux["gtKnockdownTargetID"] = nil
			end
		end
	end
end)

-- cdtweaks, NWN-ish Knockdown ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtInnateKnockdown", 1)
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
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	--
	local gainAbility = spriteClassStr == "MONK" or spriteClassStr == "FIGHTER" or spriteClassStr == "FIGHTER_MAGE_THIEF" or spriteClassStr == "FIGHTER_MAGE_CLERIC"
		or (spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
	--
	if sprite:getLocalInt("gtInnateKnockdown") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtInnateKnockdown", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%INNATE_KNOCKDOWN%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 321, -- remove effects by resource
				["res"] = "%INNATE_KNOCKDOWN%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
