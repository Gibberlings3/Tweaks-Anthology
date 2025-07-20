--[[
+---------------------------------------------+
| cdtweaks, NWN-ish Disarm ability for Rogues |
+---------------------------------------------+
--]]

-- NWN-ish Disarm ability (main) --

function %THIEF_DISARM%(CGameEffect, CGameSprite)
	-- Small / Medium / Large weapons --
	local weaponSizeTable = {
		["small"] = {"", "CL", "DD", "F2", "M2", "MC", "SL", "SS"},
		["medium"] = {"AX", "BS", "CB", "FS", "MS", "S1", "SC", "WH"},
		["large"] = {"BW", "F0", "F1", "F3", "FL", "GS", "HB", "Q2", "Q3", "Q4", "QS", "S0", "S2", "S3", "SP"},
	}
	--
	local function checkWeaponSize(animationType)
		for size, animationTypeList in pairs(weaponSizeTable) do
			for _, value in ipairs(animationTypeList) do
				if value == animationType then
					return size
				end
			end
		end
		return "none" -- should not happen
	end
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
	--
	local conditionalString = "InventoryFull(Myself)"
	-- Get source's currently selected weapon
	local sourceSelectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	-- Get target's currently selected weapon
	local targetSelectedWeapon = GT_Sprite_GetSelectedWeapon(CGameSprite)
	if targetSelectedWeapon["launcher"] then
		targetSelectedWeapon["weapon"] = targetSelectedWeapon["launcher"] -- CItem
		targetSelectedWeapon["resref"] = targetSelectedWeapon["launcher"].pRes.resref:get()
		targetSelectedWeapon["header"] = targetSelectedWeapon["launcher"].pRes.pHeader -- Item_Header_st
		targetSelectedWeapon["slot"] = targetSelectedWeapon["launcherSlot"] -- int
	end
	-- MAIN --
	-- Check if inventory is full
	if not GT_EvalConditional["parseConditionalString"](sourceSprite, sourceSprite, conditionalString) then
		-- check if NONDROPABLE
		if EEex_IsBitUnset(targetSelectedWeapon["weapon"].m_flags, 0x3) then
			-- check if DROPPABLE
			if EEex_IsBitSet(targetSelectedWeapon["header"].itemFlags, 0x2) then
				-- check if CURSED
				if EEex_IsBitUnset(targetSelectedWeapon["header"].itemFlags, 0x4) then
					--
					local sourceAnimationType = EEex_CastUD(sourceSelectedWeapon["header"].animationType, "CResRef"):get()
					local targetAnimationType = EEex_CastUD(targetSelectedWeapon["header"].animationType, "CResRef"):get()
					-- sanity check (only darts are supposed to have a null animation)
					if (targetAnimationType ~= "") or (EEex_Resource_ItemCategoryIDSToSymbol(targetSelectedWeapon["header"].itemType) == "DART") then
						-- Fetch components of check
						local roll = Infinity_RandomNumber(1, 20) -- 1d20
						--
						local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
						--
						local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
						--
						local weaponSizeModifier = 0
						local sourceWeaponSize = checkWeaponSize(sourceAnimationType)
						local targetWeaponSize = checkWeaponSize(targetAnimationType)
						--
						if (sourceWeaponSize == "small" and targetWeaponSize == "medium") or (sourceWeaponSize == "medium" and targetWeaponSize == "large") then
							weaponSizeModifier = -2
						elseif (sourceWeaponSize == "medium" and targetWeaponSize == "small") or (sourceWeaponSize == "large" and targetWeaponSize == "medium") then
							weaponSizeModifier = 2
						elseif sourceWeaponSize == "small" and targetWeaponSize == "large" then
							weaponSizeModifier = -4
						elseif sourceWeaponSize == "large" and targetWeaponSize == "small" then
							weaponSizeModifier = 4
						end
						--
						local thac0 = sourceActiveStats.m_nTHAC0 -- base thac0 (STAT 7)
						local luck = sourceActiveStats.m_nLuck -- STAT 32
						local thac0BonusRight = sourceActiveStats.m_THAC0BonusRight -- this should include the bonus from the weapon + str + wspecial.2da + op288 (STAT 170) + op284 (STAT 166) + stylbonu.2da
						--local meleeTHAC0Bonus = sourceActiveStats.m_nMeleeTHAC0Bonus -- op284 (STAT 166)
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
						--
						local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(sourceSelectedWeapon["ability"].damageType, targetActiveStats)
						--
						if GT_EvalConditional["parseConditionalString"](sourceSprite, CGameSprite, conditionalString) then
							-- compute attack roll (am I missing something...?)
							local success = false
							local modifier = luck + thac0BonusRight + thac0VsTypeBonus + racialEnemy - attackRollPenalty + attackOfOpportunity + strikingFromInvisibility - invisibleTarget + weaponSizeModifier - 6
							--
							local criticalHitMod, criticalMissMod = GT_Sprite_GetCriticalModifiers(sourceSprite)
							--
							local m_nTimeStopCaster = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nTimeStopCaster
							--
							if (roll >= 20 - criticalHitMod) or EEex_BAnd(targetActiveStats.m_generalState, 0x100029) ~= 0 or m_nTimeStopCaster == sourceSprite.m_id then -- automatic hit
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
									string.format("%s : %d %s %d = %d : %s",
										Infinity_FetchString(%feedback_strref_disarm%), roll, modifier < 0 and "-" or "+", modifier, roll + modifier, Infinity_FetchString(%feedback_strref_hit%)),
									0xBED7D7
								)
								--
								sourceSprite:applyEffect({
									["effectID"] = 122, -- create inventory item
									["durationType"] = 1,
									["effectAmount"] = targetSelectedWeapon["weapon"].m_useCount1,
									["m_effectAmount2"] = targetSelectedWeapon["weapon"].m_useCount2,
									["m_effectAmount3"] = targetSelectedWeapon["weapon"].m_useCount3,
									["res"] = targetSelectedWeapon["resref"],
									["sourceID"] = sourceSprite.m_id,
									["sourceTarget"] = sourceSprite.m_id,
								})
								-- restore ``CItem`` flags
								do
									local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
									--
									for i = 18, 33 do -- inventory slots
										local item = items:get(i) -- CItem
										--
										if item then -- sanity check
											local resref = item.pRes.resref:get()
											--
											if resref == targetSelectedWeapon["resref"] then
												if item.m_flags ~= targetSelectedWeapon["weapon"].m_flags then
													if item.m_useCount1 == targetSelectedWeapon["weapon"].m_useCount1 then
														if item.m_useCount2 == targetSelectedWeapon["weapon"].m_useCount2 then
															if item.m_useCount3 == targetSelectedWeapon["weapon"].m_useCount3 then
																item.m_flags = targetSelectedWeapon["weapon"].m_flags
																break
															end
														end
													end
												end
											end
										end
									end
								end
								--
								CGameSprite:applyEffect({
									["effectID"] = 143, -- create item in slot
									["durationType"] = 1,
									["effectAmount"] = targetSelectedWeapon["slot"],
									["res"] = "%THIEF_DISARM%",
									["sourceID"] = CGameEffect.m_sourceId,
									["sourceTarget"] = CGameEffect.m_sourceTarget,
								})
								CGameSprite:applyEffect({
									["effectID"] = 112, -- remove item
									["res"] = "%THIEF_DISARM%",
									["sourceID"] = CGameEffect.m_sourceId,
									["sourceTarget"] = CGameEffect.m_sourceTarget,
								})
								-- make sure to unequip ammo (apparently, if you disarm a launcher, the corresponding ammo is still equipped)
								do
									local items = CGameSprite.m_equipment.m_items -- Array<CItem*,39>
									--
									for i = 11, 13 do -- ammo slots
										local item = items:get(i) -- CItem
										--
										if item then -- sanity check
											local resref = item.pRes.resref:get()
											--
											local responseString = EEex_Action_ParseResponseString(string.format('XEquipItem("%s",Myself,%d,UNEQUIP)', resref, i))
											responseString:executeResponseAsAIBaseInstantly(CGameSprite)
											--
											responseString:free()
										end
									end
								end
							else
								-- display feedback message
								GT_Sprite_DisplayMessage(sourceSprite,
									string.format("%s : %d %s %d = %d : %s",
										Infinity_FetchString(%feedback_strref_disarm%), roll, modifier < 0 and "-" or "+", modifier, roll + modifier, Infinity_FetchString(%feedback_strref_miss%)),
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
							["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				else
					CGameSprite:applyEffect({
						["effectID"] = 139, -- display string
						["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			else
				CGameSprite:applyEffect({
					["effectID"] = 139, -- display string
					["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		else
			CGameSprite:applyEffect({
				["effectID"] = 139, -- display string
				["effectAmount"] = %feedback_strref_cannot_be_disarmed%,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	else
		sourceSprite:applyEffect({
			["effectID"] = 139, -- display string
			["effectAmount"] = %feedback_strref_inventory_full%,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
	end
end

-- Make it castable at will. Prevent spell disruption. Check if melee weapon equipped --

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)
	local curAction = sprite.m_curAction
	local spriteAux = EEex_GetUDAux(sprite)

	if not (curAction.m_actionID == 31 and resref == "%THIEF_DISARM%" and changeAmount < 0) then
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
		spriteAux["gt_NWN_Disarm_TargetID"] = curAction.m_acteeID.m_Instance
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

-- Cast the "real" spl (ability) when the attack frame counter is 6 --

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
	if sprite:getLocalInt("gtNWNDisarm") == 1 then
		if selectedWeapon["ability"].type == 1 then
			if sprite.m_nSequence == 0 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_ATTACK)
				if spriteAux["gt_NWN_Disarm_TargetID"] then
					-- retrieve / forget target sprite
					local targetSprite = EEex_GameObject_Get(spriteAux["gt_NWN_Disarm_TargetID"])
					spriteAux["gt_NWN_Disarm_TargetID"] = nil
					--
					targetSprite:applyEffect({
						["effectID"] = 138, -- set animation
						["dwFlags"] = 4, -- SEQ_DAMAGE
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
					targetSprite:applyEffect({
						["effectID"] = 402, -- invoke lua
						["res"] = "%THIEF_DISARM%",
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					})
				end
			end
		end
	end
end)

-- Forget about ``spriteAux["gt_NWN_Disarm_TargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	if sprite:getLocalInt("gtNWNDisarm") == 1 then
		if not (action.m_actionID == 113 and action.m_string1.m_pchData:get() == "%THIEF_DISARM%") then
			if spriteAux["gt_NWN_Disarm_TargetID"] ~= nil then
				spriteAux["gt_NWN_Disarm_TargetID"] = nil
			end
		end
	end
end)

-- cdtweaks, NWN-ish Disarm ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or Infinity_GetCurrentScreenName() == 'CHARGEN' then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNDisarm", 1)
		--
		local effectCodes = {
			{["op"] = 172}, -- remove spell
			{["op"] = 171}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["res"] = "%THIEF_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteINT = sprite.m_derivedStats.m_nINT
	-- Check if rogue class -- single/multi/(complete)dual
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	--
	local gainAbility = isThiefAll and spriteINT >= 13
	--
	if sprite:getLocalInt("gtNWNDisarm") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNDisarm", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%THIEF_DISARM%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
