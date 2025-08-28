-- racial enemy bonus to thac0 and damage --

function GT_Sprite_GetRacialEnemyBonus(attacker, target)
	local toReturn = 0
	--
	if attacker:getActiveStats().m_nHatedRace > 0 then
		if GT_Sprite_CheckIDS(target, attacker:getActiveStats().m_nHatedRace, 4) then
			toReturn = 4
		end
	end
	--
	return toReturn
end

