--[[
+---------------------------------------------------------------------------------------+
| cdtweaks, NWN-ish Overwhelming/Devastating Critical class feat for Trueclass Fighters |
+---------------------------------------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function(mainHandResRef)
		-- Update tracking var
		sprite:setLocalString("gtNWNDevastatingCritical", mainHandResRef)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%TRUECLASS_FIGHTER_DEVASTATING_CRITICAL%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 182, -- Use EFF file while ITM is equipped
			["durationType"] = 9,
			["res"] = string.upper(mainHandResRef), -- ITM
			["m_res2"] = "%TRUECLASS_FIGHTER_DEVASTATING_CRITICAL%B", -- EFF
			["m_sourceRes"] = "%TRUECLASS_FIGHTER_DEVASTATING_CRITICAL%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / class / pips
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	--
	local selectedWeaponProficiencyType = selectedWeapon["header"].proficiencyType
	-- get launcher if needed
	if selectedWeapon["launcher"] then
		local pHeader = selectedWeapon["launcher"].pRes.pHeader -- Item_Header_st
		--
		selectedWeaponProficiencyType = pHeader.proficiencyType
		selectedWeapon["resref"] = selectedWeapon["launcher"].pRes.resref:get()
	end
	--
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = sprite.m_derivedStats.m_nKit == 0 and "TRUECLASS" or EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteSTR = sprite.m_derivedStats.m_nSTR
	--
	local grandmastery = string.format("ProficiencyGT(Myself,%d,4)", selectedWeaponProficiencyType)
	--
	local applyAbility = spriteClassStr == "FIGHTER" and spriteLevel1 >= 30 and (spriteKitStr == "TRUECLASS" or spriteKitStr == "MAGESCHOOL_GENERALIST") and GT_Trigger_EvalConditional["parseConditionalString"](sprite, sprite, grandmastery) and spriteSTR >= 19
	--
	if sprite:getLocalString("gtNWNDevastatingCritical") == "" then
		if applyAbility then
			apply(selectedWeapon["resref"])
		end
	else
		if applyAbility then
			-- Check if weapon resref has changed since the last application
			if selectedWeapon["resref"] ~= sprite:getLocalString("gtNWNDevastatingCritical") then
				apply(selectedWeapon["resref"])
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalString("gtNWNDevastatingCritical", "")
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%TRUECLASS_FIGHTER_DEVASTATING_CRITICAL%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op402 listener --

function %TRUECLASS_FIGHTER_DEVASTATING_CRITICAL%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
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
	--
	local immunityToKillTarget = "EEex_IsImmuneToOpcode(Myself,13)"
	--
	if not GT_Trigger_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, immunityToKillTarget) then
		EEex_GameObject_ApplyEffect(sourceSprite,
		{
			["effectID"] = 139, -- Display string
			["effectAmount"] = %feedback_strref_devastating_crit_hit%,
			["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
			["m_sourceType"] = CGameEffect.m_sourceType,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
		--
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
				["saveMod"] = -1 * savebonus,
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
	--
	local effect = context.effect -- CGameEffect
	local damageAmount = effect.m_effectAmount
	--
	local attackRoll = context.attackRoll
	local isCritical = context.isCritical
	local criticalHitMod, criticalMissMod = GT_Sprite_GetCriticalModifiers(attacker, context.isLeftHand)
	--
	local weapon = context.weapon -- CItem
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
			if GT_Trigger_EvalConditional["parseConditionalString"](attacker, attacker, grandmastery) then
				if isCritical then
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

