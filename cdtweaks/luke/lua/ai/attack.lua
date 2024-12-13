--[[
+--------------------+
| AI (weapon attack) |
+--------------------+
--]]

-- look for [PC] (if attacker is [EVILCUTOFF]), then for HATEDRACE, then for whatever is passed as argument. Set GOODCUTOFF / EVILCUTOFF accordingly --

local function GT_AI_Attack_GetTargetList(array) -- f.i.: array = {"UNDEAD", "0.<HATEDRACE_PLACEHOLDER>.MAGE_ALL"}
	local toReturn = {}
	--
	local m_nHatedRace = EEex_LuaDecode_Object:getActiveStats().m_nHatedRace
	if m_nHatedRace > 0 then
		-- Duplicate the values
		local i = 1
		while i <= #array do
			if string.find(array[i], "<HATEDRACE_PLACEHOLDER>") then
				local hatedRaceSymbol = string.gsub(array[i], "<HATEDRACE_PLACEHOLDER>", GT_Resource_IDSToSymbol["race"][m_nHatedRace])
				table.insert(array, i, hatedRaceSymbol)
				i = i + 1 -- Skip the newly inserted element to avoid infinite loop
				array[i] = string.gsub(array[i], "<HATEDRACE_PLACEHOLDER>", "0")
			end
			i = i + 1
		end
	else
		for i = #array, 1, -1 do
			array[i] = string.gsub(array[i], "<HATEDRACE_PLACEHOLDER>", "0")
		end
	end
	-- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MAGE_ALL"} / array = {"UNDEAD", "0.0.MAGE_ALL"}
	if EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
		-- give priority to [PC]
		for _, v in ipairs(array) do
			local str = "PC." .. v
			local str = EEex_ReplaceRegex(str, "(?:\\.0)+$", "") -- delete trailing ".0" -> NB.: Unlike some other systems, in Lua a modifier can only be applied to a character class; there is no way to group patterns under a modifier
			table.insert(toReturn, str)
		end
		--
		for _, v in ipairs(array) do
			local str = "GOODCUTOFF." .. v
			local str = EEex_ReplaceRegex(str, "(?:\\.0)+$", "")
			table.insert(toReturn, str)
		end
	elseif EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
		for _, v in ipairs(array) do
			local str = "EVILCUTOFF." .. v
			local str = EEex_ReplaceRegex(str, "(?:\\.0)+$", "")
			table.insert(toReturn, str)
		end
	end
	--
	return toReturn
end

-- check if the currently equipped weapon is effective / can deal non-zero damage --

local function GT_AI_Attack_WeaponCheck(weaponResRef, sprite)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_SIZE"])
	--
	local toReturn = false
	--
	EEex_LuaDecode_Object:setStoredScriptingTarget("gt_target", sprite)
	local isWeaponValid = EEex_Trigger_ParseConditionalString('WeaponEffectiveVs(EEex_Target("gt_target"),MAINHAND) \n WeaponCanDamage(EEex_Target("gt_target"),MAINHAND)')
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaDecode_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 1 and effect.m_effectAmount2 == sprite.m_id and effect.m_res:get() == weaponResRef then
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
	if not isWeaponValid:evalConditionalAsAIBase(EEex_LuaDecode_Object) then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaDecode_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 1,
					["durationType"] = 4, -- delay / permanent
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["res"] = weaponResRef,
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaDecode_Object.m_id,
					["sourceTarget"] = EEex_LuaDecode_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	isWeaponValid:free()
	--
	return toReturn
end

-- check if the target is immune / can bounce projectile --

local function GT_AI_Attack_ProjectileCheck(projectileIdx, msectype, sprite)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_SIZE"])
	--
	local toReturn = false
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaDecode_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 2 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == projectileIdx then
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
				EEex_GameObject_ApplyEffect(EEex_LuaDecode_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 2,
					["durationType"] = 4,
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = projectileIdx, -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when combat ends
					["sourceID"] = EEex_LuaDecode_Object.m_id,
					["sourceTarget"] = EEex_LuaDecode_Object.m_id,
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

-- extra (custom) checks --

local function GT_AI_Attack_ExtraCheck(string, sprite)
	local attackerINT = EEex_LuaDecode_Object:getActiveStats().m_nINT
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", attackerINT)]["AI_DURATION_DICE_SIZE"])
	--
	local toReturn = false
	--
	local conditionalString = EEex_Trigger_ParseConditionalString(string)
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local timerExpired = false
	local timerAlreadyApplied = false
	--
	EEex_Utility_IterateCPtrList(EEex_LuaDecode_Object.m_timedEffectList, function(effect)
		if effect.m_effectId == 401 and effect.m_special == stats["GT_AI_TIMER"] and effect.m_dWFlags == 1 and effect.m_effectAmount == 3 and effect.m_effectAmount2 == sprite.m_id and effect.m_effectAmount3 == GT_Utility_AI_SimpleHash(string) then
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
	--EEex_LuaDecode_Object:setStoredScriptingTarget("gt_target", sprite)
	--
	if not conditionalString:evalConditionalAsAIBase(sprite) then
		if timerExpired then
			-- do nothing, target not valid
		else
			if not timerAlreadyApplied then
				EEex_GameObject_ApplyEffect(EEex_LuaDecode_Object,
				{
					["effectID"] = 401, -- Set extended stat
					["special"] = stats["GT_AI_TIMER"],
					["dwFlags"] = 1, -- mode: set
					["effectAmount"] = 3,
					["durationType"] = 4, -- delay / permanent
					["duration"] = 6 * math.random(dnum, dnum * dsize),
					["m_effectAmount2"] = sprite.m_id, -- p3
					["m_effectAmount3"] = GT_Utility_AI_SimpleHash(string), -- p4
					["m_sourceRes"] = "GTAITMRS", -- non-empty parent resref so that we can clear it when the combat ends
					["sourceID"] = EEex_LuaDecode_Object.m_id,
					["sourceTarget"] = EEex_LuaDecode_Object.m_id,
				})
			end
			toReturn = true
		end
	else
		toReturn = true
	end
	--
	conditionalString:free()
	--
	return toReturn
end

-- check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

local function GT_AI_Attack_InPartyCheck(sprite)
	local toReturn = false
	--
	EEex_LuaDecode_Object:setStoredScriptingTarget("gt_target", sprite)
	local inParty = EEex_Trigger_ParseConditionalString('InParty(EEex_Target("gt_target"))')
	--
	local attackerEA = EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly
	--
	if attackerEA > 200 then -- EVILCUTOFF
		toReturn = true
	else
		if not inParty:evalConditionalAsAIBase(EEex_LuaDecode_Object) then
			toReturn = true
		end
	end
	--
	inParty:free()
	--
	return toReturn
end

-- MAIN --

function GT_AI_Attack(table)
	local equipment = EEex_LuaDecode_Object.m_equipment -- CGameSpriteEquipment
	local mainHand = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local mainHandResRef = mainHand.pRes.resref:get()
	local mainHandHeader = mainHand.pRes.pHeader -- Item_Header_st
	local mainHandAbility = EEex_Resource_GetItemAbility(mainHandHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local attackerActiveStats = EEex_Sprite_GetActiveStats(EEex_LuaDecode_Object)
	--
	local toReturn = nil -- CGameSprite
	--
	local targetArray = GT_AI_Attack_GetTargetList(table["targetIDS"])
	--
	for _, aiObjectType in ipairs(targetArray) do
		local spriteArray = EEex_Sprite_GetAllOfTypeInRange(EEex_LuaDecode_Object, GT_AI_ObjectType[aiObjectType], EEex_LuaDecode_Object:virtual_GetVisualRange(), nil, nil, nil)
		if mainHandAbility.type == 1 then -- melee weapon
			spriteArray = GT_Utility_AI_SortSpritesByIsometricDistance(spriteArray)
		else -- ranged / launcher
			spriteArray = GT_Utility_AI_ShuffleSprites(spriteArray)
		end
		--
		for _, itrSprite in ipairs(spriteArray) do
			local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
			--
			if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				if itrSpriteActiveStats.m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						if GT_AI_Attack_WeaponCheck(mainHandResRef, itrSprite) then
							if mainHandAbility.type == 1 or GT_AI_Attack_ProjectileCheck(mainHandAbility.missileType - 1, mainHandAbility.secondaryType, itrSprite) then
								if not table["extra"] or GT_AI_Attack_ExtraCheck(table["extra"], itrSprite) then
									if GT_AI_Attack_InPartyCheck(itrSprite) then
										toReturn = itrSprite -- CGameSprite
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
	--
	::continue::
	-- default to the nearest enemy if necessary
	if toReturn == nil then
		local nearest
		if EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			nearest = GT_AI_ObjectType["GOODCUTOFF"]:evalAsAIBase(EEex_LuaDecode_Object)
		elseif EEex_LuaDecode_Object.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			nearest = GT_AI_ObjectType["EVILCUTOFF"]:evalAsAIBase(EEex_LuaDecode_Object)
		end
		--
		if EEex_GameObject_IsSprite(nearest) then -- sanity check (``nearest`` may be ``nil`` if invisible...?)
			if EEex_BAnd(nearest:getActiveStats().m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				if nearest:getActiveStats().m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					if EEex_IsBitUnset(nearest:getActiveStats().m_generalState, 0x4) or attackerActiveStats.m_bSeeInvisible > 0 then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						if GT_AI_Attack_InPartyCheck(nearest) then
							toReturn = nearest
						end
					end
				end
			end
		end
	end
	--
	return toReturn -- CGameSprite
end
