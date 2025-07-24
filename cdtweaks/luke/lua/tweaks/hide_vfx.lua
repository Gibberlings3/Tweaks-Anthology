--[[
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| cdtweaks: hide op215 and hardcoded animations played by opcodes 153, 155, 156, 201, 204, 205, 223, 226, 259, 197, 198, 200, 202, 203, 207, 227, 228, 299 from invisible enemies |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local func
	func = function(effect)
		if effect.m_effectId == 0xB1 or effect.m_effectId == 0x11B then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				if func(CGameEffectBase) then
					return true
				end
			end
		elseif effect.m_effectId == 0xD7 or effect.m_effectId == 0x99 or effect.m_effectId == 0x9B or effect.m_effectId == 0x9C then
			return true
		end
		--
		return false
	end
	--
	local effectList = {sprite.m_timedEffectList, sprite.m_equipedEffectList}
	-- Check creature's state
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	--
	local applyCondition = EEex_IsBitSet(spriteGeneralState, 0x4) and sprite.m_typeAI.m_EnemyAlly > 200 -- STATE_INVISIBLE && EVILCUTOFF
	--
	if applyCondition then
		-- Play visual effect (215), Sanctuary (153), Minor globe overlay (155), Protection from normal missiles overlay (156)
		for _, list in ipairs(effectList) do
			EEex_Utility_IterateCPtrList(list, function(effect)
				local found = func(effect)
				-- hide visual effects
				if found then
					if effect.m_res3:get() ~= "GTHIDVFX" then
						--Infinity_DisplayString("hiding vfx...")
						--
						effect.m_res2:set(effect.m_res:get()) -- store for later restoration
						if not (effect.m_effectId == 177 or effect.m_effectId == 283) then
							effect.m_dWFlags = effect.m_effectId == 215 and effect.m_dWFlags or 1 -- custom overlay
						end
						effect.m_res:set("") -- null overlay
						effect.m_res3:set("GTHIDVFX")
					end
				end
			end)
		end
		-- Spell Deflection/Reflection/Trap
		sprite:applyEffect({
			["effectID"] = 0x141, -- Remove effects by resource (321)
			["noSave"] = true, -- just in case...?
			["res"] = "GTHIDVFX",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		EEex_GameObject_ApplyEffect(sprite,
		{
			["effectID"] = 0x123, -- Disable visual effects (291)
			["noSave"] = true, -- just in case...?
			["dwFlags"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "GTHIDVFX",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	else
		-- Play visual effect (215), Sanctuary (153), Minor globe overlay (155), Protection from normal missiles overlay (156)
		for _, list in ipairs(effectList) do
			EEex_Utility_IterateCPtrList(list, function(effect)
				local found = func(effect)
				-- restore visual effects
				if found then
					if effect.m_res3:get() == "GTHIDVFX" then
						--Infinity_DisplayString("restoring vfx...")
						--
						if effect.m_effectId ~= 215 and effect.m_effectId ~= 177 and effect.m_effectId ~= 283 then
							effect.m_dWFlags = effect.m_res2:get() == "" and 0 or 1
						end
						effect.m_res:set(effect.m_res2:get())
						effect.m_res2:set("")
						effect.m_res3:set("")
					end
				end
			end)
		end
		--
		sprite:applyEffect({
			["effectID"] = 0x141, -- Remove effects by resource (321)
			["noSave"] = true, -- just in case...?
			["res"] = "GTHIDVFX",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
end)

