-- cdtweaks: Defensive Roll class feat for rogues --

function GTDEFRLL(op403CGameEffect, CGameEffect, CGameSprite)
	local damageTypeStr = GT_Resource_IDSToSymbol["dmgtype"][CGameEffect.m_dWFlags]
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
	local setTimer = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksDefensiveRollTimer","LOCALS",7200)')
	--
	local roll = Infinity_RandomNumber(1, 20) -- 1d20
	-- If the character is struck by a potentially lethal blow, he makes a save vs. breath. If successful, he takes only half damage from the blow.
	if CGameEffect.m_effectId == 0xC and damageTypeStr ~= "STUNNING" and CGameEffect.m_slotNum == -1 and CGameEffect.m_sourceType == 0 and CGameEffect.m_sourceRes:get() == "" -- base weapon damage (all damage types but STUNNING)
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
