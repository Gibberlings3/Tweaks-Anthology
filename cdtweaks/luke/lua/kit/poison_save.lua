--[[
+------------------------------------------------------+
| cdtweaks, NWN-ish Poison Save kit feat for Assassins |
+------------------------------------------------------+
--]]

local cdtweaks_PoisonSave_FeedbackString = {
	["Poison"] = true,
	["Poisoned"] = true,
}

local cdtweaks_PoisonSave_FeedbackIcon = {
	[6] = true, -- Poisoned
	[101] = true, -- Decaying (see ``CLERIC_DOLOROUS_DECAY``)
}

-- Apply ability --

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
			["res"] = "%ASSASSIN_POISON_SAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%ASSASSIN_POISON_SAVE%", -- lua function
			["m_sourceRes"] = "%ASSASSIN_POISON_SAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%ASSASSIN_POISON_SAVE%",
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
				["res"] = "%ASSASSIN_POISON_SAVE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- This class feat grants a +2 bonus on saving throws against poison effects --

function %ASSASSIN_POISON_SAVE%(op403CGameEffect, CGameEffect, CGameSprite)
	local language = Infinity_GetINIString('Language', 'Text', 'should not happen')
	local displaySubtitles = Infinity_GetINIValue('Program Options', 'Display Subtitles', -1)
	--
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	if CGameEffect.m_effectId == 25 or (CGameEffect.m_effectId == 12 and EEex_IsMaskSet(CGameEffect.m_dWFlags, 0x200000)) then -- Poison || Damage (poison)
		local success = false
		local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		local spriteRoll = -1
		local adjustedRoll = -1
		local spriteSaveVS = -1
		local feedbackStr = ""
		--
		local savingThrowTable = {
			[0] = {CGameSprite.m_saveVSSpellRoll, spriteActiveStats.m_nSaveVSSpell, 14003},
			[1] = {CGameSprite.m_saveVSBreathRoll, spriteActiveStats.m_nSaveVSBreath, 14004},
			[2] = {CGameSprite.m_saveVSDeathRoll, spriteActiveStats.m_nSaveVSDeath, 14009},
			[3] = {CGameSprite.m_saveVSWandsRoll, spriteActiveStats.m_nSaveVSWands, 14006},
			[4] = {CGameSprite.m_saveVSPolyRoll, spriteActiveStats.m_nSaveVSPoly, 14005}
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
			EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
				if effect.m_sourceRes:get() == parentResRef then
					if effect.m_effectId == 142 then -- Display portrait icon
						if cdtweaks_PoisonSave_FeedbackIcon[effect.m_dWFlags] then
							effect.m_sourceRes:set("CDREMOVE")
						end
					elseif effect.m_effectId == 174 and effect.m_durationType == 7 then -- Play sound
						if math.floor((effect.m_duration - effect.m_effectAmount5) / 15) == CGameEffect.m_duration then
							effect.m_sourceRes:set("CDREMOVE")
						end
					elseif effect.m_effectId == 139 then -- Display string
						-- temporarily set language to English
						Infinity_SetLanguage("en_US", 0)
						--
						if cdtweaks_PoisonSave_FeedbackString[Infinity_FetchString(effect.m_effectAmount)] then
							effect.m_sourceRes:set("CDREMOVE")
						end
						-- restore original language / subtitles
						Infinity_SetLanguage(language, displaySubtitles)
					end
				end
			end)
			-- Remove ancillary effects
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDREMOVE",
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
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 401 and effect.m_special == stats["GT_IMMUNITY"] and effect.m_effectAmount == 3 and effect.m_res:get() == parentResRef then
				duration = effect.m_effectAmount2
				return true
			end
		end)
		--
		if duration > -1 then
			if CGameEffect.m_effectId == 142 then -- Display portrait icon
				if cdtweaks_PoisonSave_FeedbackIcon[CGameEffect.m_dWFlags] then
					return true
				end
			elseif CGameEffect.m_effectId == 139 then -- Display string
				-- temporarily set language to English
				Infinity_SetLanguage("en_US", 0)
				--
				if cdtweaks_PoisonSave_FeedbackString[Infinity_FetchString(CGameEffect.m_effectAmount)] then
					-- restore original language / subtitles
					Infinity_SetLanguage(language, displaySubtitles)
					--
					return true
				end
				-- restore original language / subtitles
				Infinity_SetLanguage(language, displaySubtitles)
			elseif CGameEffect.m_effectId == 174 then -- Play sound
				if CGameEffect.m_duration == duration and (CGameEffect.m_durationType == 3 or CGameEffect.m_durationType == 4) then
					return true
				end
			end
		elseif CGameEffect.m_effectId == 139 then
			-- temporarily set language to English
			Infinity_SetLanguage("en_US", 0)
			--
			if cdtweaks_PoisonSave_FeedbackString[Infinity_FetchString(CGameEffect.m_effectAmount)] then
				-- make sure instantaneous effects get applied *after* the poison opcode (so that we can properly block them)
				if CGameEffect.m_durationType == 0 or CGameEffect.m_durationType == 1 or CGameEffect.m_durationType == 9 or CGameEffect.m_durationType == 10 then
					-- 0-sec delay (instantaneous delay)
					CGameEffect.m_durationType = 4
					CGameEffect.m_duration = 0
				end
			end
			-- restore original language / subtitles
			Infinity_SetLanguage(language, displaySubtitles)
		end
	end
end
