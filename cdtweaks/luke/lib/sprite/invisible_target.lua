-- Check if the target is invisible. If so, then the attacker gets a malus of -4 to thac0 (unless it can see invisible sprites) --

function GT_Sprite_InvisibleTargetPenalty(attacker, target)
	local toReturn = 0
	--
	if EEex_IsBitSet(target:getActiveStats().m_generalState, 0x4) or EEex_IsBitSet(target:getActiveStats().m_generalState, 22) then
		if attacker:getActiveStats().m_bSeeInvisible == 0 then
			toReturn = 4
		end
	end
	--
	return toReturn
end

