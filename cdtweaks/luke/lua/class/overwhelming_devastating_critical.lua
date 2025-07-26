--[[
+---------------------------------------------------------------------------------------+
| cdtweaks, NWN-style Overwhelming/Devastating Critical class feat for Trueclass Fighters |
+---------------------------------------------------------------------------------------+
--]]

-- op408 listener --

%FIGHTER_DEVASTATING_CRITICAL%P = {

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
		if projectileTypeStr == "GT_Devastating_Critical" then
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
	end,
}

-- op402 listener --

function %FIGHTER_DEVASTATING_CRITICAL%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--[[
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
	--
	local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
	--
	local gtabmod = GT_Resource_2DA["gtabmod"]
	--
	local savebonus = tonumber(gtabmod[string.format("%s", sourceActiveStats.m_nSTR)]["BONUS"])
	if selectedWeapon["ability"].type == 2 then -- if ranged, make it scale with Dexterity
		savebonus = tonumber(gtabmod[string.format("%s", sourceActiveStats.m_nDEX)]["BONUS"])
	end
	--]]
	local deathImmunity = "EEex_IsImmuneToOpcode(Myself,13)"
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, deathImmunity) then
		--[[
		EEex_GameObject_ApplyEffect(sourceSprite,
		{
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_devastating_crit_hit%,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
		--]]
		local effectCodes = {
			{["op"] = 0xD7, ["tmg"] = 1, ["res"] = "SPBOLTGL"}, -- feedback vfx
			{["op"] = 0xD, ["tmg"] = 4, ["p2"] = 0x4} -- kill target (normal death)
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["dwFlags"] = attributes["p2"] or 0,
				["durationType"] = attributes["tmg"] or 0,
				["res"] = attributes["res"] or "",
				["savingThrow"] = 0x4, -- save vs. death
				--["saveMod"] = -1 * savebonus,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	else
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_devastating_crit_immune%,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
	end
end

-- Overwhelming/Devastating Critical: 3x damage --
-- Devastating Critical: 2x damage (in case target is immune to critical hits) --

EEex_Sprite_AddAlterBaseWeaponDamageListener(function(context)
	local attacker = context.attacker -- CGameSprite
	local target = context.target -- CGameSprite
	--
	local effect = context.effect -- CGameEffect
	local damageAmount = effect.m_effectAmount
	--
	local attackRoll = context.attackRoll
	local isCritical = context.isCritical
	local criticalHitMod, criticalMissMod = GT_Sprite_GetCriticalModifiers(attacker, context.isLeftHand)
	--
	local weapon = context.weapon -- CItem
	local ability = context.ability -- Item_ability_st
	local launcher = context.launcher -- CItem
	--
	local proficiencyType = weapon.pRes.pHeader.proficiencyType
	-- get launcher if needed
	if launcher then
		proficiencyType = launcher.pRes.pHeader.proficiencyType
	end
	--
	local attackerClassStr = GT_Resource_IDSToSymbol["class"][attacker.m_typeAI.m_Class]
	--
	local attackerKitStr = attacker:getActiveStats().m_nKit == 0 and "TRUECLASS" or EEex_Resource_KitIDSToSymbol(attacker:getActiveStats().m_nKit)
	local attackerLevel1 = attacker:getActiveStats().m_nLevel1
	local attackerSTR = attacker:getActiveStats().m_nSTR
	--
	local grandmastery = string.format("ProficiencyGT(Myself,%d,4)", proficiencyType)
	--
	if attackerClassStr == "FIGHTER" and (attackerKitStr == "TRUECLASS" or attackerKitStr == "MAGESCHOOL_GENERALIST") and attackerSTR >= 19 then
		if effect.m_effectId == 0xC and effect.m_slotNum == -1 and effect.m_sourceType == 0 and effect.m_sourceRes:get() == "" then -- base weapon damage
			if GT_EvalConditional["parseConditionalString"](attacker, nil, grandmastery) then
				if isCritical then
					if attackerLevel1 >= 30 then
						GT_Sprite_DisplayMessage(attacker, Infinity_FetchString(%feedback_strref_devastating_crit_hit%))
						--
						if ability.type == 1 then -- melee
							EEex_GameObject_ApplyEffect(target,
							{
								["effectID"] = 402, -- Invoke lua
								["res"] = "%FIGHTER_DEVASTATING_CRITICAL%",
								["sourceID"] = attacker.m_id,
								["sourceTarget"] = target.m_id,
							})
						else -- ranged: make sure to use the same projectile as the ammo
							EEex_GameObject_ApplyEffect(attacker,
							{
								["effectID"] = 408, -- proj mutator
								["duration"] = 1,
								["durationType"] = 10,
								["res"] = "%FIGHTER_DEVASTATING_CRITICAL%P",
								["sourceID"] = attacker.m_id,
								["sourceTarget"] = attacker.m_id,
							})
							EEex_GameObject_ApplyEffect(target,
							{
								["effectID"] = 146, -- Cast spl
								["dwFlags"] = 1,
								["res"] = "%FIGHTER_DEVASTATING_CRITICAL%",
								["sourceID"] = attacker.m_id,
								["sourceTarget"] = target.m_id,
							})
						end
					else
						GT_Sprite_DisplayMessage(attacker, Infinity_FetchString(%feedback_strref_overwhelming_crit_hit%))
					end
					effect.m_effectAmount = 3 * math.floor(damageAmount / 2) -- 3x damage
				else
					-- check if critical hit averted
					if attackerLevel1 >= 30 then
						if attackRoll >= 20 - criticalHitMod then
							effect.m_effectAmount = 2 * damageAmount -- 2x damage
						end
					end
				end
			end
		end
	end
end)

