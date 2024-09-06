-- cdtweaks, Planar Turning class feat for Paladins and Clerics --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual turning
	local turnPlanarMode = function()
		sprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["durationType"] = 1,
			["dwFlags"] = 1, -- instant / ignore level
			["res"] = "%PRIEST_PLANAR_TURNING%", -- SPL file
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check if the creature is turning undead
	local turnUndeadMode = EEex_Sprite_GetModalState(sprite) == 4 and EEex_Sprite_GetModalTimer(sprite) == 0
	--
	if turnUndeadMode then
		turnPlanarMode()
	end
end)

-- cdtweaks, Planar Turning class feat for Paladins and Clerics --

function %PRIEST_PLANAR_TURNING%(CGameEffect, CGameSprite)
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	local isEvil = EEex_Trigger_ParseConditionalString("Alignment(Myself,MASK_EVIL)")
	local sourceTurnUndeadLevel = sourceSprite.m_derivedStats.m_nTurnUndeadLevel + sourceSprite.m_bonusStats.m_nTurnUndeadLevel
	--
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	local targetLevel = CGameSprite.m_derivedStats.m_nLevel1 + CGameSprite.m_bonusStats.m_nLevel1
	--
	local roll = math.random(0, 3) -- engine: ((int)((rand() & 0x7fff) << 2) >> 0xf) => generates a random number, keeps its lower 15 bits, multiplies by 2^2, divides by 2^15
	--
	if targetRaceStr == "DEMONIC" or targetRaceStr == "MEPHIT" or targetRaceStr == "IMP" or targetRaceStr == "ELEMENTAL" or targetRaceStr == "SALAMANDER" or targetRaceStr == "SOLAR" or targetRaceStr == "ANTISOLAR" or targetRaceStr == "DARKPLANATAR" or targetRaceStr == "PLANATAR" or targetRaceStr == "GENIE" then -- if extraplanar ...
		if sourceTurnUndeadLevel < (targetLevel + roll) + 5 then
			if sourceTurnUndeadLevel >= (targetLevel + roll) then -- turn
				CGameSprite:applyEffect({
					["effectID"] = 174, -- Play sound
					["durationType"] = 1,
					["res"] = "ACT_06",
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 141, -- Lighting effects
					["durationType"] = 1,
					["dwFlags"] = 24, -- Effect: Invocation air
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["durationType"] = 1,
					["res"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 24, -- Panic
					["dwFlags"] = 1, -- bypass immunity
					["noSave"] = true, -- redundant...?
					["duration"] = 60,
					["m_sourceRes"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 142, -- Feedback icon
					["dwFlags"] = 36, -- icon: panic
					["noSave"] = true,
					["duration"] = 60,
					["m_sourceRes"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 139, -- Display string
					["durationType"] = 1,
					["effectAmount"] = %feedback_strref%,
					["m_sourceRes"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		else -- destroy or take control
			if isEvil:evalConditionalAsAIBase(sourceSprite) then -- take control
				CGameSprite:applyEffect({
					["effectID"] = 174, -- Play sound
					["durationType"] = 1,
					["res"] = "ACT_06",
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 141, -- Lighting effects
					["durationType"] = 1,
					["dwFlags"] = 24, -- Effect: Invocation air
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["durationType"] = 1,
					["res"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 241, -- Control creature
					["dwFlags"] = 4, -- charm type: controlled
					["duration"] = 60,
					["m_sourceRes"] = parentResRef,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			else -- destroy
				CGameSprite:applyEffect({
					["effectID"] = 174, -- Play sound
					["durationType"] = 1,
					["res"] = "ACT_06",
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 141, -- Lighting effects
					["durationType"] = 1,
					["dwFlags"] = 24, -- Effect: Invocation air
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 13, -- Kill creature
					["durationType"] = 1,
					["dwFlags"] = 4, -- normal death
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
	--
	isEvil:free()
end
