-- Returns true if the given sprite is a party member --

function GT_Sprite_IsPartyMember(sprite)
	for i = 0, 5 do
		local partyMember = EEex_Sprite_GetInPortrait(i) -- CGameSprite
		if partyMember then -- sanity check
			if partyMember.m_id == sprite.m_id then
				return true
			end
		end
	end
	-- default
	return false
end

