-- cdtweaks, Poison Save (Assassins): This class feat grants a +2 bonus on saving throws against poison effects --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksPoisonSave", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDPSNSAV",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTPSNSAV", -- lua function
			["m_sourceRes"] = "CDPSNSAV",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "CDPSNSAV",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit
	local spriteFlags = sprite.m_baseStats.m_flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- single/multi/(complete)dual assassins
	local applyAbility = spriteClassStr == "THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	local applyAbility = applyAbility and spriteKitStr == "ASSASIN"
	--
	if sprite:getLocalInt("cdtweaksPoisonSave") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksPoisonSave", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDPSNSAV",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks, Poison Save (Assassins): This class feat grants a +2 bonus on saving throws against poison effects --

function GTPSNSAV(op403CGameEffect, CGameEffect, CGameSprite)
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	if CGameEffect.m_effectId == 25 or (CGameEffect.m_effectId == 12 and EEex_IsMaskSet(CGameEffect.m_dWFlags, 0x200000)) then -- Poison || Damage (poison)
		local success = false
		local spriteDerivedStats = CGameSprite.m_derivedStats
		local spriteBonusStats = CGameSprite.m_bonusStats
		local spriteRoll = -1
		local adjustedRoll = -1
		local spriteSaveVS = -1
		local feedbackStr = ""
		--
		local savingThrowTable = {
			[0] = {CGameSprite.m_saveVSSpellRoll, spriteDerivedStats.m_nSaveVSSpell + spriteBonusStats.m_nSaveVSSpell, 14003},
			[1] = {CGameSprite.m_saveVSBreathRoll, spriteDerivedStats.m_nSaveVSBreath + spriteBonusStats.m_nSaveVSBreath, 14004},
			[2] = {CGameSprite.m_saveVSDeathRoll, spriteDerivedStats.m_nSaveVSDeath + spriteBonusStats.m_nSaveVSDeath, 14009},
			[3] = {CGameSprite.m_saveVSWandsRoll, spriteDerivedStats.m_nSaveVSWands + spriteBonusStats.m_nSaveVSWands, 14006},
			[4] = {CGameSprite.m_saveVSPolyRoll, spriteDerivedStats.m_nSaveVSPoly + spriteBonusStats.m_nSaveVSPoly, 14005}
		}
		--
		for k, v in pairs(savingThrowTable) do
			if EEex_IsBitSet(CGameEffect.m_savingThrow, k) then
				spriteRoll = v[1]
				adjustedRoll = v[1] + 2 + CGameEffect.m_saveMod -- the greater ``CGameEffect.m_saveMod``, the easier is to succeed
				spriteSaveVS = v[2]
				feedbackStr = Infinity_FetchString(v[3])
				if adjustedRoll >= spriteSaveVS then
					success = true
				end
				break
			end
		end
		--
		if success == true then
			-- keep track of its duration (needed to remove ancillary op174 effects)
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 401, -- Set extended stat
				["dwFlags"] = 1, -- set
				["effectAmount"] = 3,
				["res"] = parentResRef,
				["m_effectAmount2"] = CGameEffect.m_duration,
				["special"] = stats["GT_IMMUNITY"],
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
			-- Mark ancillary effects
			EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(fx)
				if fx.m_sourceRes:get() == parentResRef then
					if fx.m_effectId == 142 then -- Display portrait icon
						if fx.m_dWFlags == 6 or fx.m_dWFlags == 101 then -- this includes the "Decaying" icon (see ``CLERIC_DOLOROUS_DECAY``)
							fx.m_sourceRes:set("CDREMOVE")
						end
					elseif fx.m_effectId == 174 and fx.m_durationType == 7 then -- Play sound
						if math.floor((fx.m_duration - fx.m_effectAmount5) / 15) == CGameEffect.m_duration then
							fx.m_sourceRes:set("CDREMOVE")
						end
					end
				end
			end)
			-- Remove ancillary effects
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDREMOVE",
				["durationType"] = 1,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
			-- feedback string (avoid displaying duplicate messages, i.e.: print this only if the +2 bonus makes a difference)
			if spriteRoll < spriteSaveVS then
				Infinity_DisplayString(CGameSprite:getName() .. ": " .. feedbackStr .. " : " .. adjustedRoll)
			end
			-- block op25/12
			return true
		end
	else
		-- block ancillary effects
		local duration = -1
		--
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_IMMUNITY"] and fx.m_effectAmount == 3 and fx.m_res:get() == parentResRef then
				duration = fx.m_effectAmount2
				return true
			end
		end)
		--
		if duration > -1 then
			if CGameEffect.m_effectId == 142 then -- Display portrait icon
				if CGameEffect.m_dWFlags == 6 or CGameEffect.m_dWFlags == 101 then -- this includes the "Decaying" icon (see ``CLERIC_DOLOROUS_DECAY``)
					return true
				end
			elseif CGameEffect.m_effectId == 139 then -- Display string
				if CGameEffect.m_effectAmount == 14017 or CGameEffect.m_effectAmount == 37607 then
					return true
				end
			elseif CGameEffect.m_effectId == 174 then -- Play sound
				if CGameEffect.m_duration == duration then
					return true
				end
			end
		end
	end
end
