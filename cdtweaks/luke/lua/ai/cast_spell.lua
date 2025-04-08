--[[
+-------------------------+
| AI (cast spell/ability) |
+-------------------------+
--]]

-- give priority to [PC] (if the spell is party-friendly and caster is [GOODCUTOFF]). Set GOODCUTOFF / EVILCUTOFF accordingly --

local function GT_AI_CastSpell_EA(array, mode) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}; mode (0 = source and target enemies, 1 = source and target allies)
	local toReturn = {}

	if mode == 0 then
		if EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			for _, value in ipairs(array) do
				local newValue = "PC." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
			--
			for _, value in ipairs(array) do
				local newValue = "GOODCUTOFF." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
		elseif EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			for _, value in ipairs(array) do
				local newValue = "EVILCUTOFF." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
		end
	elseif mode == 1 then
		if EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			for _, value in ipairs(array) do
				local newValue = "EVILCUTOFF." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
		elseif EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			-- give priority to [PC]
			for _, value in ipairs(array) do
				local newValue = "PC." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
			for _, value in ipairs(array) do
				local newValue = "GOODCUTOFF." .. value

				-- Add the new value
				table.insert(toReturn, newValue)
			end
		end
	end

	return toReturn
end

-- check if spellcasting is disabled (op144/145) --

local function GT_AI_CastSpell_SpellcastingDisabled(pHeader, pAbility)
	local toReturn = false
	local found = false
	--
	local spellcastingDisabled = function(effect)
		if pAbility.quickSlotType == 2 and effect.m_effectId == 144 and effect.m_dWFlags == 2 then -- location: cast spell button
			found = true
			return true
		end
		if pAbility.quickSlotType == 4 and effect.m_effectId == 144 and effect.m_dWFlags == 13 then -- location: innate ability button
			found = true
			return true
		end
		--
		if pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 0 and pHeader.itemType == 1 then
			found = true
			return true
		end
		if pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 1 and pHeader.itemType == 2 then
			found = true
			return true
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 2 and not (pHeader.itemType == 1 or pHeader.itemType == 2) then
			found = true
			return true
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 3 and EEex_IsBitUnset(pHeader.itemFlags, 14) then
			found = true
			return true
		end
	end
	--
	if EEex_Sprite_GetStat(EEex_LuaTrigger_Object, 59) == 1 and pAbility.quickSlotType == 2 and (pHeader.itemType == 1 or pHeader.itemType == 2) then -- if polymorphed
		toReturn = true
	else
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, spellcastingDisabled)
		if not found then
			EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, spellcastingDisabled)
		end
		--
		if found then
			toReturn = true
		end
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce projectile --

local function GT_AI_CastSpell_ProjectileCheck(projectileIdx, msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 10 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == projectileIdx then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_projectile = function(effect)
		if effect.m_effectId == 0x53 and effect.m_dWFlags == projectileIdx then -- Immunity to projectile (83) -> CAN block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xC5 and effect.m_dWFlags == projectileIdx and msectype ~= 4 then -- Physical mirror (197) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_projectile)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_projectile)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 10,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id,
					["m_effectAmount3"] = projectileIdx,
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce mschool --

local function GT_AI_CastSpell_MschoolCheck(mschool, msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 11 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == mschool then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_mschool = function(effect)
		if effect.m_effectId == 0xCA and effect.m_dWFlags == mschool and msectype ~= 4 then -- Reflect spell school (202) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xCC and effect.m_dWFlags == mschool and msectype ~= 4 then -- Protection from spell school (204) -> CANNOT block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xDF and effect.m_dWFlags == mschool and msectype ~= 4 then -- Spell school deflection (223) -> CANNOT block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xE3 and effect.m_dWFlags == mschool and msectype ~= 4 then -- Spell school turning (227) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_mschool)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_mschool)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 11,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = mschool, -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce msectype --

local function GT_AI_CastSpell_MsectypeCheck(msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 12 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == msectype then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_msectype = function(effect)
		if effect.m_effectId == 0xCB and effect.m_dWFlags == msectype and msectype ~= 4 then -- Reflect spell type (203) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xCD and effect.m_dWFlags == msectype and msectype ~= 4 then -- Protection from spell type (205) -> CANNOT block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xE2 and effect.m_dWFlags == msectype then -- Spell type deflection (226) -> CAN block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xE4 and effect.m_dWFlags == msectype and msectype ~= 4 then -- Spell type turning (228) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_msectype)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_msectype)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 12,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = msectype, -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce / can trap spell level --

local function GT_AI_CastSpell_LevelCheck(level, msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 13 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == level then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_trap_level = function(effect)
		if effect.m_effectId == 0x66 and effect.m_effectAmount == level then -- Immunity to spell level (102) -> CAN block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xC7 and effect.m_effectAmount == level and msectype ~= 4 then -- Reflect spell level (199) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xC8 and effect.m_dWFlags == level and msectype ~= 4 then -- Spell turning (200) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xC9 and effect.m_dWFlags == level and msectype ~= 4 then -- Spell deflection (201) -> CANNOT block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0x103 and effect.m_dWFlags == level and msectype ~= 4 then -- Spell trap (259) -> CANNOT trap effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_trap_level)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_trap_level)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 13,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = level, -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce spell resref --

local function GT_AI_CastSpell_ResRefCheck(resref, msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 14 and effect.m_effectAmount2 == sprite.m_id and effect.m_res:get() == resref then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_resref = function(effect)
		if effect.m_effectId == 0xCE and effect.m_res:get() == resref then -- Protection from spell (206) -> CAN block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xCF and effect.m_res:get() == resref and msectype ~= 4 then -- Reflect specified spell (207) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_resref)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_resref)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 14,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["res"] = resref, -- res
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the target is immune / can bounce opcode --

local function GT_AI_CastSpell_OpcodeCheck(opcode, msectype, sprite)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 15 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == opcode then
			if effect.m_durationType == 1 then
				timerExpired = true
				return true
			else
				timerAlreadyApplied = true
				return true
			end
		end
	end)
	--
	local found = false
	local immune_bounce_opcode = function(effect)
		if effect.m_effectId == 0x65 and effect.m_dWFlags == opcode then -- Immunity to effect (101) -> CAN block effects of Secondary Type ``MagicAttack``
			found = true
			return true
		elseif effect.m_effectId == 0xC6 and effect.m_dWFlags == opcode and msectype ~= 4 then -- Reflect specified effect (198) -> CANNOT bounce effects of Secondary Type ``MagicAttack``
			found = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, immune_bounce_opcode)
	if not found then
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, immune_bounce_opcode)
	end
	--
	if found then
		if timerExpired then
			-- target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaTrigger_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 15,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = opcode, -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaTrigger_Object.m_id,
					["sourceTarget"] = EEex_LuaTrigger_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	return toReturn
end

-- check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

local function GT_AI_CastSpell_InPartyCheck(sprite)
	local toReturn = false
	--
	EEex_LuaTrigger_Object:setStoredScriptingTarget("GT_AI_CastSpell_InPartyCheck", sprite)
	local inParty = EEex_Trigger_ParseConditionalString('InParty(EEex_Target("GT_AI_CastSpell_InPartyCheck"))')
	--
	local casterEA = EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly
	--
	if casterEA > 200 then -- EVILCUTOFF
		toReturn = true
	else
		if not inParty:evalConditionalAsAIBase(EEex_LuaTrigger_Object) then
			toReturn = true
		end
	end
	--
	inParty:free()
	--
	return toReturn
end

-- get (true) spell level (f.i., Secret Word is actually a level 5 spell, not 4) --

local function GT_AI_CastSpell_GetTrueSpellLevel(pHeader, pAbility)
	local toReturn = pHeader.spellLevel
	--
	if pAbility.effectCount > 0 then
		local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
		--
		for idx = 1, pAbility.effectCount do
			local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
			--
			if pEffect.spellLevel > 0 then
				toReturn = pEffect.spellLevel
				break
			end
			--
			currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
		end
	end
	--
	return toReturn
end

-- MAIN: pick target --

function GT_AI_CastSpell(table)
	local spellResRef = table["resref"]
	local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
	local spellType = spellHeader.itemType
	local casterSpellFailureAmount = nil
	--
	local casterActiveStats = EEex_Sprite_GetActiveStats(EEex_LuaTrigger_Object)
	--
	if spellType == 1 then -- Wizard
		casterSpellFailureAmount = casterActiveStats.m_nSpellFailureMage
	elseif spellType == 2 then -- Priest
		casterSpellFailureAmount = casterActiveStats.m_nSpellFailurePriest
	else
		casterSpellFailureAmount = casterActiveStats.m_nSpellFailureInnate
	end
	--
	local spellFlags = spellHeader.itemFlags
	local spellSchool = spellHeader.school
	local spellSectype = spellHeader.secondaryType
	--
	local casterLevel = EEex_Sprite_GetCasterLevelForSpell(EEex_LuaTrigger_Object, spellResRef, true)
	local spellAbility = EEex_Resource_GetSpellAbilityForLevel(spellHeader, casterLevel)
	local spellLevel = GT_AI_CastSpell_GetTrueSpellLevel(spellHeader, spellAbility)
	--
	local targetSprite = nil
	--
	local targetIDS = table["targetIDS"] -- f.i.: targetIDS = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MONK", "PLANT.ELF.SHAMAN.0.MALE.NEUTRAL"}
	--
	targetIDS = GT_AI_CastSpell_EA(targetIDS, table["mode"])
	--
	if not GT_AI_CastSpell_SpellcastingDisabled(spellHeader, spellAbility) then
		if EEex_IsBitSet(spellFlags, 25) or EEex_IsBitUnset(casterActiveStats.m_generalState, 12) or string.upper(spellResRef) == "SPWI219" then -- if Vocalize || Castable when silenced || !STATE_SILENCED
			if casterSpellFailureAmount < 60 then -- should we randomize...?
				for _, aiObjectTypeString in ipairs(targetIDS) do
					local spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, string.format("[%s]", aiObjectTypeString), EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)
					local spriteArray = GT_AI_ShuffleSprites(spriteArray)
					--
					for _, itrSprite in ipairs(spriteArray) do
						local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
						--
						if spellAbility.actionType == 5 or spellAbility.actionType == 7 then -- Ability target: Caster
							targetSprite = EEex_LuaTrigger_Object
							goto continue
						else
							if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
								if itrSpriteActiveStats.m_bSanctuary == 0 or spellAbility.actionType == 4 then -- if ``Target`` is sanctuaried, then the spell must be AoE
									if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 0x4) or (spellAbility.actionType == 4 or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
										if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 22) or (spellAbility.actionType == 4 or EEex_IsBitSet(spellFlags, 24) or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is improved/weak invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
											--
											if GT_AI_CastSpell_MschoolCheck(spellSchool, spellSectype, itrSprite) then
												if GT_AI_CastSpell_MsectypeCheck(spellSectype, itrSprite) then
													if GT_AI_CastSpell_ProjectileCheck(spellAbility.missileType - 1, spellSectype, itrSprite) then
														if GT_AI_CastSpell_ResRefCheck(spellResRef, spellSectype, itrSprite) then
															if GT_AI_CastSpell_LevelCheck(spellLevel, spellSectype, itrSprite) then
																if GT_AI_CastSpell_InPartyCheck(itrSprite) then
																	--
																	local cnt = 0
																	for _, op in ipairs(table["opcode"]) do
																		if GT_AI_CastSpell_OpcodeCheck(op, spellSectype, itrSprite) then
																			cnt = cnt + 1
																		end
																	end
																	--
																	if not table["opcode"] or cnt == #table["opcode"] then -- all checks passed
																		targetSprite = itrSprite -- CGameSprite
																		goto continue
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	--
	::continue::
	EEex_LuaTrigger_Object:setStoredScriptingTarget("gt_ScriptingTarget_CastSpell", targetSprite)
	return targetSprite ~= nil
end
