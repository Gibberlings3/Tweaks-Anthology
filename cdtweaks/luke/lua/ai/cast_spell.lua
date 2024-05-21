-- AI (cast spell/ability): pick target --

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
	--
	local targetSprite = nil
	--
	local targetArray = GT_AI_Utility_LookForPCs(table["targetIDS"], table["EA"])
	local targetArray = GT_AI_Utility_LookForHatedRace(targetArray)
	local targetArray = GT_AI_Utility_ResolveEA(targetArray, table["EA"])
	--
	if not GT_AI_Utility_SpellcastingDisabled(spellHeader, spellAbility) then
		if EEex_IsBitSet(spellFlags, 25) or EEex_IsBitUnset(casterActiveStats.m_generalState, 12) or spellResRef == "SPWI219" then -- if Silence || Castable when silenced || !STATE_SILENCED
			if casterSpellFailureAmount < 60 then
				for _, aiObjectTypeString in ipairs(targetArray) do
					local spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, aiObjectTypeString, EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)
					local spriteArray = GT_AI_Utility_ShuffleSprites(spriteArray)
					--
					for _, itrSprite in ipairs(spriteArray) do
						local spriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
						--
						if spellAbility.actionType == 5 or spellAbility.actionType == 7 then -- Ability target: Caster
							targetSprite = EEex_LuaTrigger_Object
							goto target_locked
						else
							if EEex_BAnd(spriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
								if spriteActiveStats.m_bSanctuary == 0 or spellAbility.actionType == 4 then -- if ``Target`` is sanctuaried, then the spell must be AoE
									if not EEex_IsBitSet(spriteActiveStats.m_generalState, 0x4) or (spellAbility.actionType == 4 or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
										if not EEex_IsBitSet(spriteActiveStats.m_generalState, 22) or (spellAbility.actionType == 4 or EEex_IsBitSet(spellFlags, 24) or casterActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is improved/weak invisible, then ``caster`` should be able to see through invisibility || the spell should be able to target invisible creatures || the spell is AoE
											if (spellSchool == 0 or spellSectype == 4) or GT_AI_Utility_MschoolCheck(spellSchool, itrSprite) then
												if (spellSectype == 0 or spellSectype == 4) or GT_AI_Utility_MsectypeCheck(spellSectype, itrSprite) then
													if GT_AI_Utility_ProjectileCheck(spellAbility, itrSprite) then
														if GT_AI_Utility_ResourceCheck(spellResRef, itrSprite) then
															if GT_AI_Utility_PowerLevelCheck(spellSectype, spellHeader, spellAbility, itrSprite) then
																if not table["opcode"] or GT_AI_Utility_OpcodeCheck(table["opcode"], itrSprite) then
																	if not table["stats"] or GT_AI_Utility_CheckStat(table["stats"], itrSprite) then
																		if not table["state"] or GT_AI_Utility_StateCheck(table["state"], itrSprite) then
																			if not table["splstate"] or GT_AI_Utility_CheckSpellState(table["splstate"], itrSprite) then
																				targetSprite = itrSprite
																				goto target_locked
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
		end
	end
	--
	::target_locked::
	EEex_LuaTrigger_Object:setStoredScriptingTarget("gt_target", targetSprite)
	return targetSprite ~= nil
end
