--[[
+---------------------------------------------+
| cdtweaks, Revised Archer Kit (Manyshot HLA) |
+---------------------------------------------+
--]]

-- Shoot two arrows at a time --

%ARCHER_MANYSHOT%P = {

	["typeMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
	end,

	["projectileMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		local sourceActiveStats = EEex_Sprite_GetActiveStats(originatingSprite) -- CDerivedStats
		--
		local targetSprite = EEex_GameObject_Get(originatingSprite.m_targetId) -- CGameSprite
		local targetActiveStats = EEex_Sprite_GetActiveStats(targetSprite) -- CDerivedStats
		--
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(originatingSprite)
		local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeapon["header"].itemType)
		--
		local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
		-- Bow with arrows equipped || bow with unlimited ammo equipped
		if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then
			--
			local projectile = context["projectile"] -- CProjectile
			-- Add main op12 (launcher + wspecial + ammo)
			do
				local damageBonus = sourceActiveStats.m_nDamageBonus -- op73
				local damageBonusRight = sourceActiveStats.m_DamageBonusRight -- wspecial.2da
				local missileDamageBonus = sourceActiveStats.m_nMissileDamageBonus -- op286 (STAT 168)
				-- op179
				local damageVsTypeBonus = GT_Sprite_DamageVsTypeBonus(originatingSprite, targetSprite)
				-- racial enemy
				local racialEnemy = GT_Sprite_GetRacialEnemyBonus(originatingSprite, targetSprite)
				--
				local modifier = damageBonus + damageBonusRight + missileDamageBonus + damageVsTypeBonus + racialEnemy
				--
				projectile:AddEffect(GT_Utility_DecodeEffect(
					{
						["effectID"] = 0xC, -- Damage
						["effectAmount"] = (selectedWeapon["ability"].damageDiceCount == 0 and selectedWeapon["ability"].damageDice == 0 and selectedWeapon["ability"].damageDiceBonus == 0) and 0 or (modifier + selectedWeapon["ability"].damageDiceBonus),
						["numDice"] = selectedWeapon["ability"].damageDiceCount,
						["diceSize"] = selectedWeapon["ability"].damageDice,
						["dwFlags"] = damageTypeIDS * 0x10000,
						--
						["sourceX"] = originatingSprite.m_pos.x,
						["sourceY"] = originatingSprite.m_pos.y,
						["targetX"] = targetSprite.m_pos.x,
						["targetY"] = targetSprite.m_pos.y,
						--
						["m_projectileType"] = selectedWeapon["ability"].missileType - 1,
						--
						["sourceID"] = originatingSprite.m_id,
						["sourceTarget"] = targetSprite.m_id,
					}
				))
			end
			-- Add on-hit effect(s) (ammo)
			do
				local currentEffectAddress = EEex_UDToPtr(selectedWeapon["header"]) + selectedWeapon["header"].effectsOffset + selectedWeapon["ability"].startingEffect * Item_effect_st.sizeof
				--
				for i = 1, selectedWeapon["ability"].effectCount do
					local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
					--
					projectile:AddEffect(GT_Utility_DecodeEffect(
						{
							["effectID"] = pEffect.effectID,
							["targetType"] = pEffect.targetType,
							["spellLevel"] = pEffect.spellLevel,
							["effectAmount"] = pEffect.effectAmount,
							["dwFlags"] = pEffect.dwFlags,
							["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
							["duration"] = pEffect.duration,
							["probabilityUpper"] = pEffect.probabilityUpper,
							["probabilityLower"] = pEffect.probabilityLower,
							["res"] = pEffect.res:get(),
							["numDice"] = pEffect.numDice,
							["diceSize"] = pEffect.diceSize,
							["savingThrow"] = pEffect.savingThrow,
							["saveMod"] = pEffect.saveMod,
							["special"] = pEffect.special,
							--
							["m_school"] = selectedWeapon["ability"].school,
							["m_secondaryType"] = selectedWeapon["ability"].secondaryType,
							["m_flags"] = EEex_RShift(pEffect.durationType, 8),
							["m_projectileType"] = selectedWeapon["ability"].missileType - 1,
							--
							["m_sourceRes"] = selectedWeapon["weapon"].pRes.resref:get(),
							["m_sourceType"] = 2,
							--
							["sourceX"] = originatingSprite.m_pos.x,
							["sourceY"] = originatingSprite.m_pos.y,
							["targetX"] = targetSprite.m_pos.x,
							["targetY"] = targetSprite.m_pos.y,
							--
							["sourceID"] = originatingSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
						}
					))
					--
					currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
				end
			end
			-- Add on-hit effect(s) (launcher)
			if selectedWeapon["launcher"] then
				local pHeader = selectedWeapon["launcher"].pRes.pHeader -- Item_Header_st
				--
				local pAbility
				for i = 1, pHeader.abilityCount do
					pAbility = EEex_Resource_GetCItemAbility(selectedWeapon["launcher"], i - 1) -- Item_ability_st
					if pAbility.type == 0x4 then -- Launcher
						break
					end
				end
				--
				local currentEffectAddress = EEex_UDToPtr(pHeader) + pHeader.effectsOffset + pAbility.startingEffect * Item_effect_st.sizeof
				--
				for i = 1, pAbility.effectCount do
					local pEffect = EEex_PtrToUD(currentEffectAddress, "Item_effect_st")
					--
					projectile:AddEffect(GT_Utility_DecodeEffect(
						{
							["effectID"] = pEffect.effectID,
							["targetType"] = pEffect.targetType,
							["spellLevel"] = pEffect.spellLevel,
							["effectAmount"] = pEffect.effectAmount,
							["dwFlags"] = pEffect.dwFlags,
							["durationType"] = EEex_BAnd(pEffect.durationType, 0xFF),
							["duration"] = pEffect.duration,
							["probabilityUpper"] = pEffect.probabilityUpper,
							["probabilityLower"] = pEffect.probabilityLower,
							["res"] = pEffect.res:get(),
							["numDice"] = pEffect.numDice,
							["diceSize"] = pEffect.diceSize,
							["savingThrow"] = pEffect.savingThrow,
							["saveMod"] = pEffect.saveMod,
							["special"] = pEffect.special,
							--
							["m_school"] = pAbility.school,
							["m_secondaryType"] = pAbility.secondaryType,
							["m_flags"] = EEex_RShift(pEffect.durationType, 8),
							["m_projectileType"] = pAbility.missileType - 1,
							--
							["m_sourceRes"] = selectedWeapon["launcher"].pRes.resref:get(),
							["m_sourceType"] = 2,
							--
							["sourceX"] = originatingSprite.m_pos.x,
							["sourceY"] = originatingSprite.m_pos.y,
							["targetX"] = targetSprite.m_pos.x,
							["targetY"] = targetSprite.m_pos.y,
							--
							["sourceID"] = originatingSprite.m_id,
							["sourceTarget"] = targetSprite.m_id,
						}
					))
					--
					currentEffectAddress = currentEffectAddress + Item_effect_st.sizeof
				end
			end
		end
	end,

	["effectMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameSprite_Swing] = true,
		}
		--
		if not actionSources[context.addEffectSource] then
			return
		end
	end,

}

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual passive HLA
	local apply = function()
		-- Mark the creature as 'HLA applied'
		sprite:setLocalInt("gtNWNManyshot", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%ARCHER_MANYSHOT%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 408, -- EEex: Projectile Mutator
			["durationType"] = 9,
			["res"] = "%ARCHER_MANYSHOT%P", -- Lua
			["m_sourceRes"] = "%ARCHER_MANYSHOT%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's / class / kit / levels
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- any ranger (single/multi/(complete)dual, not fallen)
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	-- Level 25+ && Archer kit
	local conditionalString = "ClassLevelGT(Myself,WARRIOR,24)"
	--
	local applyAbility = spriteKitStr == "FERALAN" and isRangerAll and GT_Trigger_EvalConditional["parseConditionalString"](sprite, sprite, conditionalString)
	--
	if sprite:getLocalInt("gtNWNManyshot") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- Do nothing
		else
			-- Mark the creature as 'HLA removed'
			sprite:setLocalInt("gtNWNManyshot", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%ARCHER_MANYSHOT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
