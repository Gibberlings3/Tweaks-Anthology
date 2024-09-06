-- cdtweaks, Fearless (Halflings): This racial feat grants a +2 bonus on saving throws against fear effects --

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
			["durationType"] = 1,
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
				["durationType"] = 1,
				["res"] = "%HALFLING_FEARLESS%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks, Fearless (Halflings): This feat grants a +2 bonus on saving throws against fear effects --

function %HALFLING_FEARLESS%(op403CGameEffect, CGameEffect, CGameSprite)
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	if CGameEffect.m_effectId == 24 then -- Panic
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
				["effectAmount"] = 2,
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
						if fx.m_dWFlags == 36 then
							fx.m_sourceRes:set("CDREMOVE")
						end
					elseif fx.m_effectId == 215 then -- Play visual effect
						if fx.m_res:get() == "CDHORROR" then
							fx.m_sourceRes:set("CDREMOVE")
						end
					elseif fx.m_effectId == 174 and fx.m_durationType == 7 then -- Play sound
						if math.floor((fx.m_duration - fx.m_effectAmount5) / 15) == CGameEffect.m_duration then
							fx.m_sourceRes:set("CDREMOVE")
						end
					elseif fx.m_effectId == 23 or fx.m_effectId == 54 or fx.m_effectId == 106 then -- morale bonus, base thac0 bonus, morale break
						fx.m_sourceRes:set("CDREMOVE")
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
			-- block op24
			return true
		end
	else
		-- block ancillary effects
		local duration = -1
		--
		EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(fx)
			if fx.m_effectId == 401 and fx.m_special == stats["GT_IMMUNITY"] and fx.m_effectAmount == 2 and fx.m_res:get() == parentResRef then
				duration = fx.m_effectAmount2
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
				if CGameEffect.m_res:get() == "CDHORROR" then
					return true
				end
			elseif CGameEffect.m_effectId == 139 then -- Display string
				if CGameEffect.m_effectAmount == 14007 or CGameEffect.m_effectAmount == 20568 then
					return true
				end
			elseif CGameEffect.m_effectId == 174 then -- Play sound
				if CGameEffect.m_duration == duration then
					return true
				end
			elseif CGameEffect.m_effectId == 23 or CGameEffect.m_effectId == 54 or CGameEffect.m_effectAmount == 106 then -- morale bonus, base thac0 bonus, morale break
				return true
			end
		end
	end
end
