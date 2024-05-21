-- cdtweaks, Animal Companion (Dire Boar): -5 Fury per second if there is no enemy in sight --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	local furyAmount = sprite:getLocalInt("gtAnmlCompBoarFuryAmount")
	if furyAmount > 100 then furyAmount = 100 end -- cap at 100
	-- internal function that decrements current Fury by 5 each second
	local decrementFury = function()
		-- Mark the creature as 'malus applied'
		sprite:setLocalInt("gtAnmlCompBoarFuryDec", 1)
		--
		local delay = 0
		for i = furyAmount, 1, -5 do
			sprite:applyEffect({
				["effectID"] = 309, -- Set local int
				["durationType"] = 4,
				["duration"] = delay,
				["dwFlags"] = 1, -- increment
				["effectAmount"] = -5,
				["res"] = "gtAnmlCo",
				["m_res2"] = "mpBoarFu",
				["m_res3"] = "ryAmount",
				["m_sourceRes"] = "GTACP_05",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			delay = delay + 1
		end
	end
	-- Check creature deathvar / fury
	local spriteScriptName = sprite.m_scriptName:get()
	local enemyInSight = EEex_Trigger_ParseConditionalString('See(NearestEnemyOf(Myself))')
	--
	if spriteScriptName == "gtAnmlCompBoar" then
		if sprite:getLocalInt("gtAnmlCompBoarFuryDec") == 0 then
			if not enemyInSight:evalConditionalAsAIBase(sprite) and furyAmount > 0 then
				decrementFury()
			end
		else
			if not enemyInSight:evalConditionalAsAIBase(sprite) and furyAmount > 0 then
				-- do nothing
			else
				sprite:setLocalInt("gtAnmlCompBoarFuryDec", 0)
				--
				sprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["durationType"] = 1,
					["res"] = "GTACP_05",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
	--
	enemyInSight:free()
end)
