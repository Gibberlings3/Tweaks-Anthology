--[[
+------------------------------------------------------+
| cdtweaks, NWN-ish Fearless racial feat for Halflings |
+------------------------------------------------------+
--]]

local cdtweaks_Fearless_FeedbackString = {
	["Panic"] = true,
	["*flees in terror*"] = true,
	["Morale Failure: Panic"] = true,
}

local cdtweaks_Fearless_FeedbackVFX = {
	["CDHORROR"] = true,
	["OHRMIND"] = true,
	["SPMINDAT"] = true,
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
		sprite:setLocalInt("cdtweaksFearless", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%HALFLING_FEARLESS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%HALFLING_FEARLESS%", -- lua function
			["m_sourceRes"] = "%HALFLING_FEARLESS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 142, -- Display portrait icon
			["durationType"] = 9,
			["dwFlags"] = %feedback_icon%,
			["m_sourceRes"] = "%HALFLING_FEARLESS%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's race
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	--
	local applyAbility = spriteRaceStr == "HALFLING"
	--
	if sprite:getLocalInt("cdtweaksFearless") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksFearless", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%HALFLING_FEARLESS%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- This feat grants a +2 bonus on saving throws against fear effects --

function %HALFLING_FEARLESS%(op403CGameEffect, CGameEffect, CGameSprite)
	local language = Infinity_GetINIString('Language', 'Text', 'should not happen')
	local displaySubtitles = Infinity_GetINIValue('Program Options', 'Display Subtitles', -1)
	--
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	if CGameEffect.m_effectId == 24 then -- Panic
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
				["effectAmount"] = 2,
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
						if effect.m_dWFlags == 36 then
							effect.m_sourceRes:set("CDREMOVE")
						end
					elseif effect.m_effectId == 215 then -- Play visual effect
						if cdtweaks_Fearless_FeedbackVFX[effect.m_res:get()] then
							effect.m_sourceRes:set("CDREMOVE")
						end
					elseif effect.m_effectId == 174 and effect.m_durationType == 7 then -- Play sound
						if math.floor((effect.m_duration - effect.m_effectAmount5) / 15) == CGameEffect.m_duration then
							effect.m_sourceRes:set("CDREMOVE")
						end
					elseif effect.m_effectId == 23 or effect.m_effectId == 54 or effect.m_effectId == 106 then -- morale bonus, base thac0 bonus, morale break
						effect.m_sourceRes:set("CDREMOVE")
					elseif effect.m_effectId == 139 then -- Display string
						-- temporarily set language to English
						Infinity_SetLanguage("en_US", 0)
						--
						if cdtweaks_Fearless_FeedbackString[Infinity_FetchString(effect.m_effectAmount)] then
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
			-- block op24
			return true
		end
	else
		-- block ancillary effects
		local duration = -1
		--
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(effect)
			if effect.m_effectId == 401 and effect.m_special == stats["GT_IMMUNITY"] and effect.m_effectAmount == 2 and effect.m_res:get() == parentResRef then
				duration = effect.m_effectAmount2
				return true
			end
		end)
		--
		if duration > -1 then
			if CGameEffect.m_effectId == 142 then -- Display portrait icon
				if CGameEffect.m_dWFlags == 36 then
					return true
				end
			elseif CGameEffect.m_effectId == 215 then -- Play visual effect
				if cdtweaks_Fearless_FeedbackVFX[CGameEffect.m_res:get()] then
					return true
				end
			elseif CGameEffect.m_effectId == 139 then -- Display string
				-- temporarily set language to English
				Infinity_SetLanguage("en_US", 0)
				--
				if cdtweaks_Fearless_FeedbackString[Infinity_FetchString(CGameEffect.m_effectAmount)] then
					-- restore original language / subtitles
					Infinity_SetLanguage(language, displaySubtitles)
					--
					return true
				end
				-- restore original language / subtitles
				Infinity_SetLanguage(language, displaySubtitles)
			elseif CGameEffect.m_effectId == 174 then -- Play sound
				if CGameEffect.m_duration == duration then
					return true
				end
			elseif CGameEffect.m_effectId == 23 or CGameEffect.m_effectId == 54 or CGameEffect.m_effectAmount == 106 then -- morale bonus, base thac0 bonus, morale break
				return true
			end
		elseif CGameEffect.m_effectId == 139 then
			-- temporarily set language to English
			Infinity_SetLanguage("en_US", 0)
			--
			if cdtweaks_Fearless_FeedbackString[Infinity_FetchString(CGameEffect.m_effectAmount)] then
				-- make sure instantaneous effects get applied *after* the panic opcode (so that we can properly block them)
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
