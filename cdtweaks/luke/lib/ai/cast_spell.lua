--[[
+-------------------------+
| AI (cast spell/ability) |
+-------------------------+
--]]

-- give priority to [PC] (if the spell is party-friendly and caster is [GOODCUTOFF]). Set GOODCUTOFF / EVILCUTOFF accordingly --

local function EA(array, onlyAlliesOfCaster) -- f.i.: array = {"UNDEAD", "0.HUMAN.MAGE_ALL", 0.0.MONK}; mode (0 = source and target enemies, 1 = source and target allies)
	local toReturn = {}

	if not onlyAlliesOfCaster then
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
	else
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

local function spellcastingDisabled(pHeader, pAbility)
	local toReturn = false
	--
	local func
	func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				if func(CGameEffectBase) then
					toReturn = true
					return true
				end
			end
		elseif pAbility.quickSlotType == 2 and effect.m_effectId == 144 and effect.m_dWFlags == 2 then -- location: cast spell button
			toReturn = true
			return true
		elseif pAbility.quickSlotType == 4 and effect.m_effectId == 144 and effect.m_dWFlags == 13 then -- location: innate ability button
			toReturn = true
			return true
		--
		elseif pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 0 and pHeader.itemType == 1 then
			toReturn = true
			return true
		elseif pAbility.quickSlotType == 2 and effect.m_effectId == 145 and effect.m_dWFlags == 1 and pHeader.itemType == 2 then
			toReturn = true
			return true
		elseif effect.m_effectId == 145 and effect.m_dWFlags == 2 and not (pHeader.itemType == 1 or pHeader.itemType == 2) then
			toReturn = true
			return true
		elseif effect.m_effectId == 145 and effect.m_dWFlags == 3 and EEex_IsBitUnset(pHeader.itemFlags, 14) then
			toReturn = true
			return true
		end
	end
	--
	if EEex_Sprite_GetStat(EEex_LuaTrigger_Object, 59) == 1 and pAbility.quickSlotType == 2 and (pHeader.itemType == 1 or pHeader.itemType == 2) then -- if polymorphed
		toReturn = true
	else
		EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, func)
		if not toReturn then
			EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, func)
		end
	end
	--
	return toReturn
end

-- check if the current target is in the party (i.e., if the attacker is GOODCUTOFF, avoid targeting charmed party members) --

local function inPartyCheck(target, flag)
	local casterEA = EEex_LuaTrigger_Object.m_typeAI.m_EnemyAlly
	--
	for i = 0, 5 do
		local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
		if partyMember then -- sanity check
			if partyMember.m_id == target.m_id then -- if the caster is a party mamber
				if casterEA < 30 then -- caster: [GOODCUTOFF]
					if not flag then -- if the spell's primary target is not an ally of the caster
						return false
					else -- see f.i. Cure Light Wounds
						break
					end
				elseif casterEA > 200 then -- caster: [EVILCUTOFF]
					break
				end
			end
		end
	end
	--
	return true
end

-- MAIN: pick target --

function GT_LuaTrigger_CastSpell(args)
	local spellResRef = args["resref"]
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
	local powerLevel = GT_AI_GetTrueSpellLevel(spellHeader, spellAbility, "spl")
	--
	local targetSprite = nil
	--
	local targetIDS = args["targetIDS"] -- f.i.: targetIDS = {"UNDEAD", "0.HUMAN.MAGE_ALL", "0.0.MONK", "PLANT.ELF.SHAMAN.0.MALE.NEUTRAL"}
	--
	targetIDS = EA(targetIDS, args["onlyAlliesOfCaster"] or false)
	--
	local spellMissileType = spellAbility.missileType -- "missile.ids"
	local projectileIndex = spellMissileType - 1 -- "projectl.ids"
	local bypassDeflectionReflectionTrap, explosionProjectile = GT_AI_IsAoEMissile(projectileIndex)
	--
	if not spellcastingDisabled(spellHeader, spellAbility) then -- op144/145
		--
		if EEex_Sprite_GetCastTimer(EEex_LuaTrigger_Object) == -1 or casterActiveStats.m_bAuraCleansing > 0 then -- aura check
			--
			if EEex_IsBitSet(spellFlags, 25) or EEex_IsBitUnset(casterActiveStats.m_generalState, 12) or string.upper(spellResRef) == "SPWI219" then -- if Vocalize || Castable when silenced || !STATE_SILENCED
				--
				if casterSpellFailureAmount < math.random(100) then -- should we randomize...? Yes!
					--
					for _, extra in ipairs(args["extra"]) do -- f.i.: ["extra"] = {{['mirrorImage'] = true, ['stoneSkin'] = true}, {['mirrorImage'] = true}, {['default'] = false}}
						--
						for _, aiObjectTypeString in ipairs(targetIDS) do
							local potentialTargets = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, string.format("[%s]", aiObjectTypeString), spellRange < EEex_LuaTrigger_Object:virtual_GetVisualRange() and spellRange or EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)
							local potentialTargets = GT_Utility_ShuffleArray(potentialTargets)
							--
							for _, itrSprite in ipairs(potentialTargets) do
								local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
								--
								if EEex_BAnd(itrSpriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
									--
									if itrSpriteActiveStats.m_bSanctuary == 0 or spellAbility.actionType == 4 then -- if ``Target`` is sanctuaried, then the spell must be AoE
										--
										if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 0x4) or (spellAbility.actionType == 4 or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
											if not EEex_IsBitSet(itrSpriteActiveStats.m_generalState, 22) or (spellAbility.actionType == 4 or EEex_IsBitSet(spellFlags, 24) or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is improved/weak invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
												--
												if GT_AI_AoERadiusCheck(spellMissileType, nil, itrSprite) then
													--
													if args["forceApplyViaOp177"] or GT_AI_HasImmunityEffects(EEex_LuaTrigger_Object, itrSprite, spellLevel, bypassDeflectionReflectionTrap == 0 and projectileIndex or explosionProjectile, spellSchool, spellSectype, spellResRef, args["opcode"], bypassDeflectionReflectionTrap, args["bypassOp101"] or 0x0, args["immunitiesVia403"] or 0x0) then
														if args["forceApplyViaOp177"] or GT_AI_HasBounceEffects(EEex_LuaTrigger_Object, itrSprite, spellLevel, bypassDeflectionReflectionTrap == 0 and projectileIndex or explosionProjectile, spellSchool, spellSectype, spellResRef, args["opcode"], bypassDeflectionReflectionTrap) then
															if args["forceApplyViaOp177"] or GT_AI_HasTrapEffect(EEex_LuaTrigger_Object, itrSprite, spellLevel, spellSectype, bypassDeflectionReflectionTrap) then
																--
																if GT_AI_ExtraCheck(EEex_LuaTrigger_Object, itrSprite, extra) then
																	--
																	if inPartyCheck(itrSprite, args["onlyAlliesOfCaster"] or false) then
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
		end
	end
	--
	::continue::
	EEex_LuaTrigger_Object:setStoredScriptingTarget("gtCastSpellTarget", targetSprite)
	return targetSprite ~= nil
end

