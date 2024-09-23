-- cdtweaks, make grease ignitable: greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

function GTGRSFLM(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local roll = Infinity_RandomNumber(1, 3)
	--
	local spriteDerivedStats = CGameSprite.m_derivedStats
	local spriteBonusStats = CGameSprite.m_bonusStats
	--
	local spriteResistFire = spriteDerivedStats.m_nResistFire + spriteBonusStats.m_nResistFire
	local spriteResistMagic = spriteDerivedStats.m_nResistMagic + spriteBonusStats.m_nResistMagic
	--
	local spriteResistMagicRoll = CGameSprite.m_magicResistRoll
	--
	local savingThrowTable = {
		[0x0] = {CGameSprite.m_saveVSSpellRoll, spriteDerivedStats.m_nSaveVSSpell + spriteBonusStats.m_nSaveVSSpell},
		[0x1] = {CGameSprite.m_saveVSBreathRoll, spriteDerivedStats.m_nSaveVSBreath + spriteBonusStats.m_nSaveVSBreath},
		[0x2] = {CGameSprite.m_saveVSDeathRoll, spriteDerivedStats.m_nSaveVSDeath + spriteBonusStats.m_nSaveVSDeath},
		[0x3] = {CGameSprite.m_saveVSWandsRoll, spriteDerivedStats.m_nSaveVSWands + spriteBonusStats.m_nSaveVSWands},
		[0x4] = {CGameSprite.m_saveVSPolyRoll, spriteDerivedStats.m_nSaveVSPoly + spriteBonusStats.m_nSaveVSPoly}
	}
	--
	local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
	--
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) and CGameEffect.m_sourceRes:get() ~= "CDFLMGRS" then
		if spriteResistFire < 100 then
			if not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
				-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
				if spriteResistMagicRoll >= spriteResistMagic then
					local success = false
					--
					for k, v in pairs(savingThrowTable) do
						if EEex_IsBitSet(CGameEffect.m_savingThrow, k) then
							local adjustedRoll = v[1] + CGameEffect.m_saveMod -- the greater ``CGameEffect.m_saveMod``, the easier is to succeed
							local spriteSaveVS = v[2]
							--
							if adjustedRoll >= spriteSaveVS then
								success = true
							end
							break
						end
					end
					--
					if success == false or EEex_IsBitSet(CGameEffect.m_special, 0x8) then -- ignore save check if the Save for Half flag is set
						local minLvlCheck = EEex_Trigger_ParseConditionalString(string.format("LevelGT(Myself,%d)", CGameEffect.m_minLevel - 1))
						if CGameEffect.m_minLevel <= 0 or minLvlCheck:evalConditionalAsAIBase(CGameSprite) then
							local maxLvlCheck = EEex_Trigger_ParseConditionalString(string.format("LevelLT(Myself,%d)", CGameEffect.m_maxLevel + 1))
							if CGameEffect.m_maxLevel <= 0 or maxLvlCheck:evalConditionalAsAIBase(CGameSprite) then
								--
								local effectCodes = {}
								--
								if roll == 1 then
									effectCodes = {
										{["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100}, -- 3d6 (save vs. breath for half)
									}
								else
									effectCodes = {
										{["op"] = 215, ["res"] = "#SHROUD", ["p2"] = 1, ["dur"] = (6 * roll) - 6}, -- play visual effect (Over target (attached))
										{["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100}, -- 3d6 (save vs. breath for half)
									}
									for i = 2, roll do
										table.insert(effectCodes, {["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100, ["tmg"] = 4, ["dur"] = (6 * i) - 6}) -- 3d6 (save vs. breath for half)
									end
								end
								--
								for _, attributes in ipairs(effectCodes) do
									CGameSprite:applyEffect({
										["effectID"] = attributes["op"] or -1,
										["dwFlags"] = attributes["p2"] or 0,
										["savingThrow"] = attributes["stype"] or 0,
										["special"] = attributes["spec"] or 0,
										["numDice"] = attributes["dnum"] or 0,
										["diceSize"] = attributes["dsize"] or 0,
										["res"] = attributes["res"] or "",
										["duration"] = attributes["dur"] or 0,
										["durationType"] = attributes["tmg"] or 0,
										["m_sourceRes"] = "CDFLMGRS",
										["sourceID"] = CGameEffect.m_sourceId,
										["sourceTarget"] = CGameEffect.m_sourceTarget,
									})
								end
							end
							--
							maxLvlCheck:free()
						end
						--
						minLvlCheck:free()
					end
				end
			end
		end
	end
	--
	immunityToDamage:free()
end

-- cdtweaks, make grease ignitable: greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksMakeGreaseIgnitable", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "CDGRSFLM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTGRSFLM", -- Lua func
			["m_sourceRes"] = "CDGRSFLM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGrease = sprite.m_derivedStats.m_bGrease
	--
	local applyCondition = spriteGrease > 0
	--
	if sprite:getLocalInt("cdtweaksMakeGreaseIgnitable") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksMakeGreaseIgnitable", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDGRSFLM",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
