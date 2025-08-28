-- op178 --

function GT_Sprite_Thac0VsTypeBonus(attacker, target)
	local toReturn = 0
	--
	EEex_Utility_IterateCPtrList(attacker:getActiveStats().m_cToHitBonusList, function(selectiveBonus)
		if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_EnemyAlly, 2) then
			if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_General, 3) then
				if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_Race, 4) then
					if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_Class, 5) then
						if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_Specifics, 6) then
							if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_Gender, 7) then
								if GT_Sprite_CheckIDS(target, selectiveBonus.m_type.m_Alignment, 8) then
									toReturn = toReturn + selectiveBonus.m_bonus
									return true -- https://gibberlings3.github.io/iesdp/opcodes/bgee.htm#op178
								end
							end
						end
					end
				end
			end
		end
	end)
	--
	return toReturn
end

