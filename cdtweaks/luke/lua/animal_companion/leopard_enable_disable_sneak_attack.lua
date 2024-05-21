-- cdtweaks, Animal Companion (Leopard): Enable/Disable custom sneak attack --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that disables the custom sneak attack
	local block = function()
		-- Mark the creature as 'malus applied'
		sprite:setLocalInt("gtAnmlCompLeopardVisible", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "GTACP_04",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		local resrefs = {"GTACP04A", "GTACP04B", "GTACP04C", "GTACP04D", "GTACP04E"}
		for _, v in ipairs(resrefs) do
			sprite:applyEffect({
				["effectID"] = 318, -- Protection from resource
				["durationType"] = 9,
				["res"] = v,
				["m_sourceRes"] = "GTACP_04",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's deathvar / state
	local spriteScriptName = sprite.m_scriptName:get()
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	-- Prevent the creature from causing bleeding damage if it is not invisible
	local isInvisible = EEex_IsBitSet(spriteGeneralState, 0x4) -- STATE_INVISIBLE (BIT4)
	--
	if spriteScriptName == "gtAnmlCompLeopard" then
		if sprite:getLocalInt("gtAnmlCompLeopardVisible") == 0 then
			if not isInvisible then
				block()
			end
		else
			if not isInvisible then
				-- do nothing
			else
				-- Mark the creature as 'malus removed'
				sprite:setLocalInt("gtAnmlCompLeopardVisible", 0)
				--
				sprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["durationType"] = 1,
					["res"] = "GTACP_04",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)
