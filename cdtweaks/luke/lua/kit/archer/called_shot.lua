--[[
+--------------------------------------------+
| cdtweaks, Revised Archer Kit (Called Shot) |
+--------------------------------------------+
--]]

-- NWN-ish Called Shot ability (main) --

function %ARCHER_CALLED_SHOT%(CGameEffect, CGameSprite)
	-- Creatures with no arms --
	local armless = {
		{"WEAPON"}, -- GENERAL.IDS
		{"DOG", "WOLF", "ANKHEG", "BASILISK", "CARRIONCRAWLER", "SPIDER", "WYVERN", "SLIME", "BEHOLDER", "DEMILICH", "BEETLE", "BIRD", "WILL-O-WISP"}, -- RACE.IDS
		{"WOLF_WORG", "ELEMENTAL_AIR", "WIZARD_EYE"}, -- CLASS.IDS
		-- ANIMATE.IDS
		{
			"DOOM_GUARD", "DOOM_GUARD_LARGER", -- 0x6000
			"SNAKE", "DANCING_SWORD", "BLOB_MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER", -- 0x7000
			"BOAR_ARCTIC", "BOAR_WILD", "BONEBAT", "WATER_WEIRD", "GT_NWN_FALCON" -- 0xE000
		},
	}
	-- Creatures with no legs --
	local legless = {
		{"WEAPON"}, -- GENERAL.IDS
		{"ANKHEG", "WYVERN", "SLIME", "BEHOLDER", "MEPHIT", "IMP", "YUANTI", "DEMILICH", "FEYR", "SALAMANDER", "BIRD", "WILL-O-WISP"}, -- RACE.IDS
		{"MEPHIT", "ELEMENTAL_AIR", "WIZARD_EYE"}, -- CLASS.IDS
		-- ANIMATE.IDS
		{
			"DOOM_GUARD", "DOOM_GUARD_LARGER", -- 0x6000
			"IMP", "SNAKE", "DANCING_SWORD", "MIST_CREATURE", "BLOB_MIST_CREATURE", "HAKEASHAR", "NISHRUU", "SNAKE_WATER", -- 0x7000
			"LEMURE", "BONEBAT", "SHADOW_SMALL", "SHADOW_LARGE", "WATER_WEIRD", "GT_NWN_FALCON" -- 0xE000
		},
	}
	--
	if CGameEffect.m_effectAmount == 0 then
		-- do nothing (AoE missile!)
	else
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId) -- CGameSprite
		--
		local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
		local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
		local targetClassStr = GT_Resource_IDSToSymbol["class"][CGameSprite.m_typeAI.m_Class]
		local targetAnimateStr = GT_Resource_IDSToSymbol["animate"][CGameSprite.m_animation.m_animation.m_animationID]
		--
		local targetIDS = {targetGeneralStr, targetRaceStr, targetClassStr, targetAnimateStr}
		-- Fetch components of check
		local roll = Infinity_RandomNumber(1, 20) -- 1d20
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite) -- CDerivedStats
		--
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite) -- CDerivedStats
		--
		local thac0 = sourceActiveStats.m_nTHAC0 -- base thac0 (STAT 7)
		local luck = sourceActiveStats.m_nLuck -- STAT 32
		local thac0BonusRight = sourceActiveStats.m_THAC0BonusRight -- this should include the bonus from the weapon + dex + wspecial.2da + op167 (STAT 72)
		--local missileTHAC0Bonus = sourceActiveStats.m_nMissileTHAC0Bonus -- op167 (STAT 72)
		-- op178
		local thac0VsTypeBonus = GT_Sprite_Thac0VsTypeBonus(sourceSprite, CGameSprite)
		-- op219
		local attackRollPenalty = GT_Sprite_AttackRollPenalty(sourceSprite, CGameSprite)
		-- racial enemy
		local racialEnemy = GT_Sprite_GetRacialEnemyBonus(sourceSprite, CGameSprite)
		-- op120
		local weaponEffectiveVs = 'WeaponEffectiveVs(EEex_Target("gtScriptingTarget"),MAINHAND)'
		-- mainhand weapon
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
		--
		local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
		--
		if GT_EvalConditional["parseConditionalString"](sourceSprite, CGameSprite, weaponEffectiveVs) then
			-- compute attack roll (am I missing something...?)
			local success = false
			local modifier = luck + thac0BonusRight + thac0VsTypeBonus - attackRollPenalty + racialEnemy - 4
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
						CGameEffect.m_effectAmount == 1 and Infinity_FetchString(%feedback_strref_called_shot_arms%) or Infinity_FetchString(%feedback_strref_called_shot_legs%), roll, modifier < 0 and "-" or "+", math.abs(modifier), roll + modifier, Infinity_FetchString(%feedback_strref_hit%)),
					0xBED7D7
				)
				--
				if CGameEffect.m_effectAmount == 1 then
					-- Called Shot (Arms): -2 thac0 penalty
					local found = false
					--
					do
						for index, symbolList in ipairs(armless) do
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
						local effectCodes = {
							{["op"] = 54, ["p1"] = -2, ["dur"] = 24}, -- base thac0 bonus
							{["op"] = 139, ["p1"] = %feedback_strref_thac0_mod%} -- feedback string
						}
						--
						for _, attributes in ipairs(effectCodes) do
							CGameSprite:applyEffect({
								["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
								["effectAmount"] = attributes["p1"] or 0,
								["duration"] = attributes["dur"] or 0,
								--["savingThrow"] = 0x2, -- save vs. breath
								--["saveMod"] = -1 * savebonus,
								["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
								["m_sourceType"] = CGameEffect.m_sourceType,
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
				elseif CGameEffect.m_effectAmount == 2 then
					-- Called Shot (Legs): -2 dex penalty, 20% movement rate penalty
					local found = false
					--
					do
						for index, symbolList in ipairs(legless) do
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
						local targetDEX = CGameSprite:getActiveStats().m_nDEX
						--
						local effectCodes = {
							{["op"] = 15, ["p1"] = (targetDEX <= 1) and 0 or ((targetDEX > 2) and -2 or -1), ["dur"] = 24}, -- dex bonus
							{["op"] = 176, ["p1"] = 80, ["p2"] = 5, ["dur"] = 24}, -- movement rate bonus (mode: multiply %)
							{["op"] = 139, ["p1"] = %feedback_strref_dex_mod%} -- feedback string
						}
						--
						for _, attributes in ipairs(effectCodes) do
							CGameSprite:applyEffect({
								["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
								["effectAmount"] = attributes["p1"] or 0,
								["dwFlags"] = attributes["p2"] or 0,
								["duration"] = attributes["dur"] or 0,
								--["savingThrow"] = 0x2, -- save vs. breath
								--["saveMod"] = -1 * savebonus,
								["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
								["m_sourceType"] = CGameEffect.m_sourceType,
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
				-- display feedback message
				GT_Sprite_DisplayMessage(sourceSprite,
					string.format("%s : %d %s %d = %d : %s",
						CGameEffect.m_effectAmount == 1 and Infinity_FetchString(%feedback_strref_called_shot_arms%) or Infinity_FetchString(%feedback_strref_called_shot_legs%), roll, modifier < 0 and "-" or "+", math.abs(modifier), roll + modifier, Infinity_FetchString(%feedback_strref_miss%)),
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
	end
end

-- Make it castable at will. Prevent spell disruption. Check if bow equipped --

EEex_Sprite_AddQuickListsCheckedListener(function(sprite, resref, changeAmount)
	local curAction = sprite.m_curAction
	local spriteAux = EEex_GetUDAux(sprite)

	local resToAux = {
		["%ARCHER_CALLED_SHOT%B"] = "gt_NWN_CallShotArm_TargetID",
		["%ARCHER_CALLED_SHOT%C"] = "gt_NWN_CallShotLeg_TargetID",
	}

	if not (sprite:getLocalInt("gtNWNCalledShot") == 1 and curAction.m_actionID == 31 and resToAux[resref] and changeAmount < 0) then
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

	-- make sure the creature is equipped with a bow
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeapon["header"].itemType)
	-- Bow with arrows equipped || bow with unlimited ammo equipped
	if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then
		-- store target id
		spriteAux[resToAux[resref]] = curAction.m_acteeID.m_Instance
		-- initialize the attack frame counter
		sprite.m_attackFrame = 0
	else
		sprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_bow_only%,
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
	local auxToRes = {
		["gt_NWN_CallShotArm_TargetID"] = "%ARCHER_CALLED_SHOT%D",
		["gt_NWN_CallShotLeg_TargetID"] = "%ARCHER_CALLED_SHOT%E",
	}
	-- make sure the creature is equipped with a bow
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	local selectedWeaponTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(selectedWeapon["header"].itemType)
	--
	if sprite:getLocalInt("gtNWNCalledShot") == 1 then
		if selectedWeaponTypeStr == "ARROW" or selectedWeaponTypeStr == "BOW" then
			if sprite.m_nSequence == 8 and sprite.m_attackFrame == 6 then -- SetSequence(SEQ_SHOOT)
				for aux, res in pairs(auxToRes) do
					if spriteAux[aux] then
						-- retrieve / forget target sprite
						local targetSprite = EEex_GameObject_Get(spriteAux[aux])
						spriteAux[aux] = nil
						-- make sure to use the currently selected projectile
						if targetSprite then
							sprite:applyEffect({
								["effectID"] = 408, -- projectile mutator
								["durationType"] = 10, -- ticks
								["duration"] = 1,
								["res"] = "%ARCHER_CALLED_SHOT%P",
								["sourceID"] = sprite.m_id,
								["sourceTarget"] = sprite.m_id,
							})
							targetSprite:applyEffect({
								["effectID"] = 146, -- cast spl
								["dwFlags"] = 1, -- instant / ignore level
								["res"] = res,
								["sourceID"] = sprite.m_id,
								["sourceTarget"] = targetSprite.m_id,
							})
						end
						--
						break
					end
				end
			end
		end
	end
end)

-- Make sure to use the currently selected projectile. Print a warning in case of AoE missiles --

%ARCHER_CALLED_SHOT%P = {

	["typeMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameAIBase_FireSpell] = true,
		}
		--
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		local projectileTypeStr = GT_Resource_IDSToSymbol["missile"][context["projectileType"]] -- The projectile type about to be decoded
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(originatingSprite)
		-- morph projectile
		if projectileTypeStr == "GT_Called_Shot" then
			return selectedWeapon["ability"].missileType
		end
	end,

	["projectileMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameAIBase_FireSpell] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
	end,

	["effectMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameAIBase_FireSpell] = true,
		}
		--
		if not actionSources[context.addEffectSource] then
			return
		end
		--
		local effect = context["effect"] -- CGameEffect
		local projectile = context["projectile"] -- CProjectile
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		if EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) then
			if effect.m_effectId == 402 then -- invoke lua
				if effect.m_res:get() == "%ARCHER_CALLED_SHOT%" then
					-- print warning
					originatingSprite:applyEffect({
						["effectID"] = 139, -- display string
						["effectAmount"] = %feedback_strref_AoE%,
						["sourceID"] = originatingSprite.m_id,
						["sourceTarget"] = originatingSprite.m_id,
					})
					-- nuke 402
					effect.m_effectAmount = 0
				end
			end
		end
	end,
}

-- Forget about ``spriteAux["gt_Aux_NWN_CallShotX_TargetID"]`` if the player manually interrupts the action --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local resToAux = {
		["%ARCHER_CALLED_SHOT%B"] = "gt_NWN_CallShotArm_TargetID",
		["%ARCHER_CALLED_SHOT%C"] = "gt_NWN_CallShotLeg_TargetID",
	}
	--
	if sprite:getLocalInt("gtNWNCalledShot") == 1 then
		if not (action.m_actionID == 113 and resToAux[action.m_string1.m_pchData:get()]) then
			for _, aux in pairs(resToAux) do
				if spriteAux[aux] ~= nil then
					spriteAux[aux] = nil
				end
			end
		end
	end
end)

-- NWN-ish Called Shot ability. Gain ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or Infinity_GetCurrentScreenName() == 'CHARGEN' then
		return
	end
	-- internal function that grants the ability
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNCalledShot", 1)
		--
		local effectCodes = {
			{["op"] = 172, ["res"] = "%ARCHER_CALLED_SHOT%B"}, -- remove spell
			{["op"] = 171, ["res"] = "%ARCHER_CALLED_SHOT%B"}, -- give spell
			{["op"] = 172, ["res"] = "%ARCHER_CALLED_SHOT%C"}, -- remove spell
			{["op"] = 171, ["res"] = "%ARCHER_CALLED_SHOT%C"}, -- give spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["res"] = attributes["res"] or "",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / kit
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- any ranger (single/multi/(complete)dual, not fallen)
	local isRangerAll = GT_Sprite_CheckIDS(sprite, class["RANGER_ALL"], 5, true)
	--
	local gainAbility = spriteKitStr == "FERALAN" and isRangerAll
	--
	if sprite:getLocalInt("gtNWNCalledShot") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNCalledShot", 0)
			--
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%ARCHER_CALLED_SHOT%B",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 172, -- remove spell
				["res"] = "%ARCHER_CALLED_SHOT%C",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
