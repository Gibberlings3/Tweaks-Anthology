--[[
+---------------------------------------------------------------------------------------+
| Utility: if a sprite is invisible, flag it (needed to implement custom sneak attacks) |
+---------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that flags the creature
	local apply = function()
		sprite:setLocalInt("gtSpriteIsInvisible", 1)
	end
	-- Check state
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	local applyCondition = EEex_IsBitSet(spriteGeneralState, 0x4) -- STATE_INVISIBLE (BIT4)
	--
	if sprite:getLocalInt("gtSpriteIsInvisible") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			sprite:setLocalInt("gtSpriteIsInvisible", 0)
		end
	end
end)
