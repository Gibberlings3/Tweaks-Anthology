--[[
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| cdtweaks, Blade Barrier vs. Time Stop                                                                                                                   |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| As currently implemented, Blade Barrier and similar spells interact very oddly with time stop effects.                                                  |
| Freeze two characters in melee range, one with a Blade Barrier (or Globe of Blades, or Circle of Bones, or any mod spell that uses the same mechanics), |
| and the spell triggers several times to no immediate effect...                                                                                          |
| until stopped time wears off. Then all of those suspended triggers hit at once, for a potential massive burst of damage.                                |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local m_nTimeStopCaster = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_nTimeStopCaster
	--local isImmuneToTimeStop = m_nTimeStopCaster == sprite.m_id or sprite.m_derivedStats.m_bImmuneToTimeStop > 0 -- N.B.: the caster is always immune to its own time stop
	-- check for Blade Barrier &c.
	local effectList = {sprite.m_equipedEffectList, sprite.m_timedEffectList} -- CGameEffectList
	local bladeBarrier = {}
	--
	local found = false
	--
	for _, list in ipairs(effectList) do
		EEex_Utility_IterateCPtrList(list, function(effect)
			if effect.m_effectId == 401 and effect.m_dWFlags == 1 and effect.m_effectAmount == 2 and effect.m_special == stats["GT_FAKE_CONTINGENCY"] then
				table.insert(bladeBarrier, effect.m_res:get())
			elseif effect.m_effectId == 0 and effect.m_dWFlags == 0 and effect.m_effectAmount == 0 and effect.m_scriptName:get() == "gtBladeBarrierTimer" then -- dummy opcode that acts as a marker/timer
				found = true
			end
		end)
	end
	--
	if next(bladeBarrier) then
		if not found then
			if m_nTimeStopCaster == -1 then
				-- cast subspell
				for _, res in ipairs(bladeBarrier) do
					sprite:applyEffect({
						["effectID"] = 146, -- Cast spl
						["dwFlags"] = 1, -- mode: cast instantly / ignore level
						["res"] = res,
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
				end
				-- set timer
				sprite:applyEffect({
					["effectID"] = 0, -- AC bonus
					["m_scriptName"] = "gtBladeBarrierTimer",
					["duration"] = 100,
					["durationType"] = 10, -- instant/limited (ticks)
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)
