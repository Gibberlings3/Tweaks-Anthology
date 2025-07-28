-- cdtweaks, Blind Fight innate feat for Berserkers --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("gtNWNBlindFight", 1)
		--
		local effectCodes = {
			{["op"] = 321, ["res"] = "%INNATE_BLIND_FIGHT%"}, -- Remove effects by resource
			{["op"] = 284, ["p1"] = 4}, -- Melee THAC0 bonus (+4)
			{["op"] = 0, ["p1"] = 4}, -- AC bonus (+4)
			{["op"] = 142, ["p2"] = %feedback_icon%}, -- Display portrait icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["m_sourceRes"] = "%INNATE_BLIND_FIGHT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's kit / state
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	-- any fighter class (single/multi/(complete)dual)
	local isFighterAll = GT_Sprite_CheckIDS(sprite, class["FIGHTER_ALL"], 5)
	-- berserkers
	local applyAbility = EEex_IsBitSet(spriteGeneralState, 0x12) -- STATE_BLIND
		and spriteKitStr == "BERSERKER"
		and isFighterAll
	--
	if sprite:getLocalInt("gtNWNBlindFight") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtNWNBlindFight", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%INNATE_BLIND_FIGHT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
