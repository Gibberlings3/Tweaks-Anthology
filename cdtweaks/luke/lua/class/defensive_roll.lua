-- cdtweaks: NWN Defensive Roll feat for Rogues --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksDefensiveRoll", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "%ROGUE_DEFENSIVE_ROLL%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%ROGUE_DEFENSIVE_ROLL%", -- Lua func
			["m_sourceRes"] = "%ROGUE_DEFENSIVE_ROLL%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags / levels
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteLevel3 = sprite.m_derivedStats.m_nLevel3
	-- KIT == SHADOWDANCER => Level 5+ ; KIT != SHADOWDANCER => Level 10+
	local applyAbility = false
	if spriteKitStr == "SHADOWDANCER" then
		if spriteClassStr == "THIEF" then
			if spriteLevel1 >= 5 then
				applyAbility = true
			end
		elseif spriteClassStr == "FIGHTER_THIEF" or spriteClassStr == "MAGE_THIEF" or spriteClassStr == "CLERIC_THIEF" then
			-- incomplete dual-class characters are not supposed to benefit from this feat
			if (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2) and spriteLevel2 >= 5 then
				applyAbility = true
			end
		elseif spriteClassStr == "FIGHTER_MAGE_THIEF" then
			if spriteLevel3 >= 5 then
				applyAbility = true
			end
		end
	else
		if spriteClassStr == "THIEF" then
			if spriteLevel1 >= 10 then
				applyAbility = true
			end
		elseif spriteClassStr == "FIGHTER_THIEF" or spriteClassStr == "MAGE_THIEF" or spriteClassStr == "CLERIC_THIEF" then
			-- incomplete dual-class characters are not supposed to benefit from this feat
			if (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2) and spriteLevel2 >= 10 then
				applyAbility = true
			end
		elseif spriteClassStr == "FIGHTER_MAGE_THIEF" then
			if spriteLevel3 >= 10 then
				applyAbility = true
			end
		end
	end
	--
	if sprite:getLocalInt("cdtweaksDefensiveRoll") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksDefensiveRoll", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "%ROGUE_DEFENSIVE_ROLL%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks: Defensive Roll class feat for rogues --

function %ROGUE_DEFENSIVE_ROLL%(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	local damageAmount = CGameEffect.m_effectAmount
	--
	local spriteHP = CGameSprite.m_baseStats.m_hitPoints
	--
	local spriteState = CGameSprite.m_derivedStats.m_generalState + CGameSprite.m_bonusStats.m_generalState
	local state = GT_Resource_SymbolToIDS["state"]
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local spriteSaveVSBreath = CGameSprite.m_derivedStats.m_nSaveVSBreath + CGameSprite.m_bonusStats.m_nSaveVSBreath
	--
	local getTimer = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("cdtweaksDefensiveRollTimer","LOCALS")')
	local setTimer = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksDefensiveRollTimer","LOCALS",2400)')
	--
	local roll = Infinity_RandomNumber(1, 20) -- 1d20
	-- If the character is struck by a potentially lethal blow, he makes a save vs. breath. If successful, he takes only half damage from the blow.
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskUnset(CGameEffect.m_dWFlags, dmgtype["STUNNING"]) and CGameEffect.m_slotNum == -1 and CGameEffect.m_sourceType == 0 and CGameEffect.m_sourceRes:get() == "" -- base weapon damage (all damage types but STUNNING)
		and EEex_BAnd(spriteState, state["CD_STATE_NOTVALID"]) == 0
		and spriteSaveVSBreath <= roll
		and damageAmount >= spriteHP
		and getTimer:evalConditionalAsAIBase(CGameSprite)
	then
		CGameEffect.m_effectAmount = math.floor(damageAmount / 2)
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 139, -- Display string
			["durationType"] = 1,
			["effectAmount"] = %feedback_strref%,
			["sourceID"] = op403CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			["sourceTarget"] = op403CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
		})
		setTimer:executeResponseAsAIBaseInstantly(CGameSprite)
	end
	--
	getTimer:free()
	setTimer:free()
end
