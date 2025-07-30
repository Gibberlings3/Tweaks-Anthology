--[[
+--------------------------------------------------------+
| cdtweaks, NWN-ish Defensive Roll class feat for Rogues |
+--------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNDefensiveRoll", 1)
	end
	-- Check creature's class / kit / flags / levels
	local class = GT_Resource_SymbolToIDS["class"]
	--
	--local spriteKitStr = GT_Resource_IDSToSymbol["kit"][EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- KIT == SHADOWDANCER => Level 5+ ; KIT != SHADOWDANCER => Level 10+
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	--
	local isShadowDancer = spriteKitStr == "SHADOWDANCER"
	--
	local conditionalString = "ClassLevelGT(Myself,ROGUE,9)"
	if isShadowDancer then
		conditionalString = "ClassLevelGT(Myself,ROGUE,4)"
	end
	--
	local applyAbility = isThiefAll and GT_EvalConditional["parseConditionalString"](sprite, nil, conditionalString)
	--
	if sprite:getLocalInt("gtNWNDefensiveRoll") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNDefensiveRoll", 0)
		end
	end
end)

-- If the character is struck by a potentially lethal blow, he makes a save vs. breath. If successful, he takes only half damage from the blow --

EEex_Sprite_AddAlterBaseWeaponDamageListener(function(context)
	local target = context.target -- CGameSprite
	local attacker = context.attacker -- CGameSprite
	--
	local effect = context.effect -- CGameEffect
	--
	local damageAmount = effect.m_effectAmount
	--
	local targetHP = target.m_baseStats.m_hitPoints
	local targetSaveVSBreathRoll = target.m_saveVSBreathRoll
	--
	local targetActiveStats = EEex_Sprite_GetActiveStats(target)
	--
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local conditionalString = '!GlobalTimerNotExpired("gtNWNDefensiveRollTimer","LOCALS")'
	local responseString = 'SetGlobalTimer("gtNWNDefensiveRollTimer","LOCALS",2400)'
	--
	local ability = context.ability -- Item_ability_st
	--
	if target:getLocalInt("gtNWNDefensiveRoll") == 1 then
		--
		if GT_EvalConditional["parseConditionalString"](target, nil, conditionalString) then
			--
			if effect.m_effectId == 0xC and EEex_IsMaskUnset(effect.m_dWFlags, dmgtype["STUNNING"]) and effect.m_slotNum == -1 and effect.m_sourceType == 0 and effect.m_sourceRes:get() == "" then -- base weapon damage (all damage types but STUNNING)
				--
				if EEex_BAnd(targetActiveStats.m_generalState, 0x100029) == 0 then -- !(STATE_SLEEPING | STATE_STUNNED | STATE_HELPLESS | STATE_FEEBLEMINDED)
					--
					if damageAmount >= targetHP then
						--
						if targetActiveStats.m_nSaveVSBreath <= targetSaveVSBreathRoll then
							--
							effect.m_effectAmount = math.floor(damageAmount / 2)
							--
							if ability.type == 1 then -- melee
								EEex_GameObject_ApplyEffect(target,
								{
									["effectID"] = 139, -- Display string
									["effectAmount"] = %feedback_strref%,
									["sourceID"] = target.m_id,
									["sourceTarget"] = target.m_id,
								})
							else -- ranged
								attacker.m_curProjectile:AddEffect(GT_Utility_DecodeEffect(
									{
										["effectID"] = 139, -- Display string
										["effectAmount"] = %feedback_strref%,
										--
										["sourceX"] = attacker.m_pos.x,
										["sourceY"] = attacker.m_pos.y,
										["targetX"] = target.m_pos.x,
										["targetY"] = target.m_pos.y,
										--
										["m_projectileType"] = ability.missileType - 1,
										["m_sourceRes"] = context.weapon.cResRef:get(),
										["m_sourceType"] = 2,
										--
										["sourceID"] = attacker.m_id,
										["sourceTarget"] = target.m_id,
									}
								))
							end
							--
							GT_ExecuteResponse["parseResponseString"](target, nil, responseString)
						end
					end
				end
			end
		end
	end
end)
