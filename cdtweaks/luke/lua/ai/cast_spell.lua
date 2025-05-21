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
	--
	local spellcastingDisabled = function(effect)
		if pAbility.quickSlotType == 2 and effect.m_effectId == 144 and effect.m_dWFlags == 2 then -- location: cast spell button
			toReturn = true
			return true
		end
		if pAbility.quickSlotType == 4 and effect.m_effectId == 144 and effect.m_dWFlags == 13 then -- location: innate ability button
			toReturn = true
			return true
		end
		--
		if pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 0 and pHeader.itemType == 1 then
			toReturn = true
			return true
		end
		if pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 1 and pHeader.itemType == 2 then
			toReturn = true
			return true
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 2 and not (pHeader.itemType == 1 or pHeader.itemType == 2) then
			toReturn = true
			return true
		end
		if effect.m_effectId == 145 and effect.m_dWFlags == 3 and EEex_IsBitUnset(pHeader.itemFlags, 14) then
			toReturn = true
			return true
		end
	end
	--
	if EEex_Sprite_GetStat(EEex_LuaTrigger_Object, 59) == 1 and pAbility.quickSlotType == 2 and (pHeader.itemType == 1 or pHeader.itemType == 2) then -- if polymorphed
		toReturn = true
	else
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, spellcastingDisabled)
		if not toReturn then
			EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, spellcastingDisabled)
		end
	end
	--
	return toReturn
end

-- The following module provides functions to calculate SHA digest --

local sha = require("gt.sha2")

-- check if the target is immune to the specified level/projectile/school/sectype/resref/opcode(s) --

local function GT_AI_CastSpell_HasImmunityEffects(target, level, projectileType, school, sectype, resref, opcodes, flags, savetype)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaTrigger_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(projectileType) .. tostring(school) .. tostring(sectype) .. resref .. (opcodes and GT_LuaTool_ArrayToString(opcodes) or "nil") .. tostring(flags) .. tostring(savetype))
	--
	local found = GT_Sprite_HasImmunityEffects(target, level, projectileType, school, sectype, resref, opcodes, flags, savetype)
	--
	if found then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 0 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 0,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	return toReturn
end

-- check if the target can bounce the specified level/projectile/school/sectype/resref/opcode(s) --

local function GT_AI_CastSpell_HasBounceEffects(target, level, projectileType, school, sectype, resref, opcodes, flags)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaTrigger_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(projectileType) .. tostring(school) .. tostring(sectype) .. resref .. (opcodes and GT_LuaTool_ArrayToString(opcodes) or "nil") .. tostring(flags))
	--
	local found = GT_Sprite_HasBounceEffects(target, level, projectileType, school, sectype, resref, opcodes, flags)
	--
	if found then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 1 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 1,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	return toReturn
end

-- check if the target can trap the specified level --

local function GT_AI_CastSpell_HasTrapEffect(target, level, sectype, flags)
	local casterINT = EEex_LuaTrigger_Object:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(EEex_LuaTrigger_Object)
	if not aux["gtAI_DetectableStates_Aux"] then
		aux["gtAI_DetectableStates_Aux"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", casterINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(sectype) .. tostring(flags))
	--
	local found = GT_Sprite_HasTrapEffect(target, level, sectype, flags)
	--
	if found then
		for _, v in ipairs(aux["gtAI_DetectableStates_Aux"]) do
			if v.mode == 2 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
					end
				end
			end
		end
		-- timer not set: target valid
		table.insert(aux["gtAI_DetectableStates_Aux"],
			{
				["hash"] = hash,
				["id"] = target.m_id,
				["expirationTime"] = 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
				["mode"] = 2,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
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
	local spellRange = spellAbility.range * 16
	local spellLevel = GT_AI_CastSpell_GetTrueSpellLevel(spellHeader, spellAbility)
	--
	local targetSprite = nil
	--
	local targetIDS = table["targetIDS"] -- f.i.: targetIDS = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MONK", "PLANT.ELF.SHAMAN.0.MALE.NEUTRAL"}
	--
	targetIDS = GT_AI_CastSpell_EA(targetIDS, table["mode"])
	--
	local spellMissileType = spellAbility.missileType -- "missile.ids"
	local projectileIndex = spellMissileType - 1 -- "projectl.ids"
	local bypassDeflectionReflectionTrap, explosionProjectile = GT_AI_IsAoEMissile(projectileIndex)
	--
	if not GT_AI_CastSpell_SpellcastingDisabled(spellHeader, spellAbility) then
		if EEex_Sprite_GetCastTimer(EEex_LuaTrigger_Object) == -1 or casterActiveStats.m_bAuraCleansing > 0 then -- aura check
			if EEex_IsBitSet(spellFlags, 25) or EEex_IsBitUnset(casterActiveStats.m_generalState, 12) or string.upper(spellResRef) == "SPWI219" then -- if Vocalize || Castable when silenced || !STATE_SILENCED
				if casterSpellFailureAmount < 60 then -- should we randomize...?
					for _, aiObjectTypeString in ipairs(targetIDS) do
						local spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, string.format("[%s]", aiObjectTypeString), spellRange < EEex_LuaTrigger_Object:virtual_GetVisualRange() and spellRange or EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)
						local spriteArray = GT_AI_ShuffleSprites(spriteArray)
						--
						for _, itrSprite in ipairs(spriteArray) do
							local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
							--
							if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
								--
								if itrSpriteActiveStats.m_bSanctuary == 0 or spellAbility.actionType == 4 then -- if ``Target`` is sanctuaried, then the spell must be AoE
									if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 0x4) or (spellAbility.actionType == 4 or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
										if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 22) or (spellAbility.actionType == 4 or EEex_IsBitSet(spellFlags, 24) or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is improved/weak invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
											--
											if GT_AI_AoERadiusCheck(spellMissileType, nil, itrSprite) then
												--
												if GT_AI_CastSpell_HasImmunityEffects(itrSprite, spellLevel, explosionProjectile == -1 and projectileIndex or explosionProjectile, spellSchool, spellSectype, spellResRef, table["opcode"], bypassDeflectionReflectionTrap, table["ignoreOp101"] or 0x0) then
													if GT_AI_CastSpell_HasBounceEffects(itrSprite, spellLevel, explosionProjectile == -1 and projectileIndex or explosionProjectile, spellSchool, spellSectype, spellResRef, table["opcode"], bypassDeflectionReflectionTrap) then
														if GT_AI_CastSpell_HasTrapEffect(itrSprite, spellLevel, spellSectype, bypassDeflectionReflectionTrap) then
															--
															if GT_AI_CastSpell_InPartyCheck(itrSprite) then
																--
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
	--
	::continue::
	EEex_LuaTrigger_Object:setStoredScriptingTarget("gt_ScriptingTarget_CastSpell", targetSprite)
	return targetSprite ~= nil
end

