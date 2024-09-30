-- cdtweaks, NWN-ish Knockdown ability. Creatures already on the ground / levitating / etc. --

local cdtweaks_ImmuneToKnockdown = {
	{"WEAPON"}, -- GENERAL.IDS
	{"DRAGON", "BEHOLDER", "ANKHEG", "SLIME", "DEMILICH", "WILL-O-WISP", "SPECTRAL_UNDEAD", "SHADOW", "SPECTRE", "WRAITH", "MIST", "GENIE", "ELEMENTAL", "SALAMANDER"}, -- RACE.IDS
	{"WIZARD_EYE", "SPECTRAL_TROLL", "SPIDER_WRAITH"}, -- CLASS.IDS
	-- ANIMATE.IDS
	{
		"DOOM_GUARD", "DOOM_GUARD_LARGER",
		"SNAKE", "BLOB_MIST_CREATURE", "MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER", "DANCING_SWORD",
		"SHADOW_SMALL", "SHADOW_LARGE", "WATER_WEIRD"
	},
}

-- cdtweaks, NWN-ish Knockdown ability --

function %INNATE_KNOCKDOWN%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	-- Check creature's currently selected weapon
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	-- Get personal space
	local sourcePersonalSpace = sourceSprite.m_animation.m_animation.m_personalSpace
	local targetPersonalSpace = CGameSprite.m_animation.m_animation.m_personalSpace
	--
	local inWeaponRange = EEex_Trigger_ParseConditionalString('InWeaponRange(EEex_Target("GT_InnateKnockdownTarget"))')
	--
	local attackOneRound = EEex_Action_ParseResponseString('AttackOneRound(EEex_Target("GT_InnateKnockdownTarget"))')
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local targetClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
	local targetAnimateStr = GT_Resource_IDSToSymbol["animate"][CGameSprite.m_animation.m_animation.m_animationID]
	--
	local targetIDS = {targetGeneralStr, targetRaceStr, targetClassStr, targetAnimateStr}
	-- Melee weapon equipped!
	if not isWeaponRanged:evalConditionalAsAIBase(sourceSprite) then
		if CGameEffect.m_effectAmount == 0 then
			sourceSprite:setStoredScriptingTarget("GT_InnateKnockdownTarget", CGameSprite)
			-- check range
			if inWeaponRange:evalConditionalAsAIBase(sourceSprite) then
				--
				local effectCodes = {
					{["op"] = 401, ["p2"] = 1, ["p1"] = 2, ["tmg"] = 10, ["dur"] = 1, ["spec"] = stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]}, -- set extended stat
					{["op"] = 284, ["tmg"] = 1, ["p1"] = -4}, -- melee thac0 bonus
					{["op"] = 142, ["tmg"] = 1, ["p2"] = %feedback_icon_canKnockdown%}, -- feedback icon
					{["op"] = 248, ["tmg"] = 1, ["res"] = "%INNATE_KNOCKDOWN%B"}, -- melee hit effect
				}
				--
				for _, attributes in ipairs(effectCodes) do
					sourceSprite:applyEffect({
						["effectID"] = attributes["op"] or -1,
						["effectAmount"] = attributes["p1"] or 0,
						["dwFlags"] = attributes["p2"] or 0,
						["special"] = attributes["spec"] or 0,
						["res"] = attributes["res"] or "",
						["duration"] = attributes["dur"] or 0,
						["durationType"] = attributes["tmg"] or 0,
						["m_sourceRes"] = "%INNATE_KNOCKDOWN%",
						["m_sourceType"] = CGameEffect.m_sourceType,
						["sourceID"] = sourceSprite.m_id,
						["sourceTarget"] = sourceSprite.m_id,
					})
				end
				--
				attackOneRound:queueResponseOnAIBase(sourceSprite)
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_outOfRange%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		elseif CGameEffect.m_effectAmount == 1 then
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
					-- SLOT_FIST is always equipped, even if not in use... As a result, we want to apply op39 via op182...
					local fistResRef = {}
					if CGameSprite.m_typeAI.m_Class == class["MONK"] then
						local monkfist = GT_Resource_2DA["monkfist"]
						for lvl = 1, 50 do
							if GT_LuaTool_KeyExists(GT_Resource_2DA, "monkfist", tostring(lvl), "RESREF") then
								fistResRef[monkfist[tostring(lvl)]["RESREF"]] = true
							end
						end
					else
						local items = CGameSprite.m_equipment.m_items -- Array<CItem*,39>
						local item = items:get(10) -- CItem
						if item then
							fistResRef[item.pRes.resref:get()] = true -- should be "FIST.ITM"
						end
					end
					-- set ``savebonus``
					local savebonus = 0
					if (sourcePersonalSpace - targetPersonalSpace) > 0 then
						savebonus = -4
					elseif (sourcePersonalSpace - targetPersonalSpace) < 0 then
						savebonus = 4
					end
					--
					local effectCodes = {}
					for resref, _ in pairs(fistResRef) do
						table.insert(effectCodes, {["op"] = 182, ["res"] = resref, ["res2"] = "GTPRONE"}) -- apply EFF while FIST/MFIST[1-8] is equipped (i.e. always). We need this to bypass op101 and make op39 uncurable (i.e. immune to op2)
					end
					table.insert(effectCodes, {["op"] = 206, ["p1"] = %feedback_strref_alreadyProne%, ["res"] = "%INNATE_KNOCKDOWN%B"}) -- protection from spell
					--
					for _, attributes in ipairs(effectCodes) do
						CGameSprite:applyEffect({
							["effectID"] = attributes["op"] or -1,
							["effectAmount"] = attributes["p1"] or 0,
							["duration"] = 6,
							["savingThrow"] = 0x4, -- save vs. death
							["saveMod"] = savebonus,
							["m_res2"] = attributes["res2"] or "",
							["m_sourceRes"] = "%INNATE_KNOCKDOWN%B",
							["m_sourceType"] = 1,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				else
					CGameSprite:applyEffect({
						["effectID"] = 139, -- display string
						["effectAmount"] = %feedback_strref_tooLarge%,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_immune%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	else
		sourceSprite:applyEffect({
			["effectID"] = 139, -- display string
			["effectAmount"] = %feedback_strref_meleeOnly%,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
	end
	--
	inWeaponRange:free()
	isWeaponRanged:free()
	attackOneRound:free()
end

-- cdtweaks, NWN-ish Knockdown ability. Make sure one and only one attack roll is performed --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	--
	if sprite:getLocalInt("cdtweaksKnockdown") == 1 then
		if GT_Utility_EffectCheck(sprite, {["op"] = 0xF8, ["res"] = "%INNATE_KNOCKDOWN%B"}) then
			if sprite.m_startedSwing == 1 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 0 and not isWeaponRanged:evalConditionalAsAIBase(sprite) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 1)
			elseif (sprite.m_startedSwing == 0 and sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1) or isWeaponRanged:evalConditionalAsAIBase(sprite) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
				--
				sprite.m_curAction.m_actionID = 0 -- nuke current action
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%INNATE_KNOCKDOWN%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			-- in case the character dies while swinging...
			if sprite:getLocalInt("gtCGameSpriteStartedSwing") == 1) then
				sprite:setLocalInt("gtCGameSpriteStartedSwing", 0)
			end
		end
	end
	--
	isWeaponRanged:free()
end)

-- cdtweaks, NWN-ish Knockdown ability. Make sure it cannot be disrupted --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if sprite:getLocalInt("cdtweaksKnockdown") == 1 then
		local stats = GT_Resource_SymbolToIDS["stats"]
		--
		if action.m_actionID == 31 and action.m_string1.m_pchData:get() == "%INNATE_KNOCKDOWN%" then
			if EEex_Sprite_GetCastTimer(sprite) == -1 then
				action.m_actionID = 113 -- ForceSpell()
				--
				sprite.m_castCounter = 0
			else
				action.m_actionID = 0 -- nuke current action
				--
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%INNATE_KNOCKDOWN%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_auraFree%,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		else
			if EEex_Sprite_GetStat(sprite, stats["GT_IGNORE_ACTION_ADD_SPRITE_STARTED_ACTION_LISTENER"]) ~= 2 then
				EEex_GameObject_ApplyEffect(sprite,
				{
					["effectID"] = 321, -- remove effects by resource
					["res"] = "%INNATE_KNOCKDOWN%",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
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
		sprite:setLocalInt("cdtweaksKnockdown", 1)
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
	if sprite:getLocalInt("cdtweaksKnockdown") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksKnockdown", 0)
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
