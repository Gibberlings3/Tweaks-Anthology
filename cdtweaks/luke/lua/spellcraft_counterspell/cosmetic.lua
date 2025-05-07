-- Maintain SEQ_READY when counterspelling --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	if sprite:getLocalInt("gtCounterSpell") == 1 then
		if EEex_Sprite_GetLocalInt(sprite, "gtCounterSpellMode") == 1 and sprite.m_nSequence == 6 and sprite.m_curAction.m_actionID == 0 then
			sprite:applyEffect({
				["effectID"] = 146, -- Cast spell
				["res"] = "%INNATE_COUNTERSPELL%Y",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
