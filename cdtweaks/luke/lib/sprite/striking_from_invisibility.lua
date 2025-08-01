-- Check if the attacker is striking from invisibility --

function GT_Sprite_StrikingFromInvisibilityBonus(attacker, target)
	local toReturn = 0
	--
	local m_nBackstabDamageMultiplier = attacker:getActiveStats().m_nBackstabDamageMultiplier
	local m_generalState = attacker:getActiveStats().m_generalState
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(attacker)
	--
	local dexmod = GT_Resource_2DA["dexmod"]
	local targetACDexBonus = tonumber(dexmod[string.format("%s", target:getActiveStats().m_nDEX)]["AC"])
	--
	if EEex_IsBitSet(m_generalState, 0x4) then -- if STATE_INVISIBLE
		if selectedWeapon["ability"].type == 1 then -- if melee weapon
			if m_nBackstabDamageMultiplier >= 2 and targetACDexBonus < 0 then -- https://gibberlings3.github.io/iesdp/opcodes/bgee.htm#op20
				toReturn = 4 - targetACDexBonus
			else
				toReturn = 4
			end
		end
	end
	--
	return toReturn
end

