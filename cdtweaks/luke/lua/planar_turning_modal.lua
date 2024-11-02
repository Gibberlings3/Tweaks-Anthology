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
			["res"] = "CDPLNTRN", -- SPL file
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
