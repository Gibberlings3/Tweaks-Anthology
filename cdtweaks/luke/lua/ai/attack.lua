-- AI (weapon attack): pick target --

function GT_AI_Attack(table)
	local equipment = EEex_LuaTrigger_Object.m_equipment -- CGameSpriteEquipment
	local mainHand = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local mainHandResRef = mainHand.pRes.resref:get()
	local mainHandHeader = mainHand.pRes.pHeader -- Item_Header_st
	local mainHandAbility = EEex_Resource_GetItemAbility(mainHandHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local attackerActiveStats = EEex_Sprite_GetActiveStats(EEex_LuaTrigger_Object)
	--
	local targetSprite = nil
	--
	local targetArray = GT_AI_Utility_LookForPCs(table["targetIDS"], "sourceAndTargetEnemies")
	local targetArray = GT_AI_Utility_LookForHatedRace(targetArray)
	local targetArray = GT_AI_Utility_ResolveEA(targetArray, "sourceAndTargetEnemies")
	--
	for _, aiObjectTypeString in ipairs(targetArray) do
		local spriteArray = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, aiObjectTypeString, EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)
		if mainHandAbility.type == 1 then -- melee weapon
			spriteArray = GT_AI_Utility_SortSprites(spriteArray)
		else -- ranged / launcher
			spriteArray = GT_AI_Utility_ShuffleSprites(spriteArray)
		end
		--
		for _, itrSprite in ipairs(spriteArray) do
			local spriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
			--
			if EEex_BAnd(spriteActiveStats.m_generalState, 0xFC0) == 0 then -- skip dead creatures (this also includes "frozen" / "petrified" creatures...)
				if spriteActiveStats.m_bSanctuary == 0 then -- ``Target`` must not be sanctuaried
					if not (EEex_IsBitSet(spriteActiveStats.m_generalState, 4)) or (attackerActiveStats.m_bSeeInvisible > 0) then -- if ``Target`` is invisible, then ``attacker`` must be able to see through invisibility
						if GT_AI_Utility_WeaponEffectiveVs(mainHandResRef, itrSprite) then
							if GT_AI_Utility_WeaponCanDamage(mainHandResRef, itrSprite) then
								if mainHandAbility.type == 1 or GT_AI_Utility_ProjectileCheck(mainHandAbility, itrSprite) then
									if not table["stats"] or GT_AI_Utility_CheckStat(table["stats"], itrSprite) then
										if not table["state"] or GT_AI_Utility_StateCheck(table["state"], itrSprite) then
											if not table["splstate"] or GT_AI_Utility_CheckSpellState(table["splstate"], itrSprite) then
												if GT_AI_Utility_InParty(itrSprite) then
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
	--
	::target_locked::
	EEex_LuaTrigger_Object:setStoredScriptingTarget("gt_target", targetSprite)
	return targetSprite ~= nil
end
