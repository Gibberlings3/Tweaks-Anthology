-- extra (additional) checks (f.i.: {['mirrorImage'] = {true, true}, ['stoneSkin'] = {true, true}}) --
-- ['mirrorImage'] = true -> flag the targeted creature as such depending on source INT --
-- ['webbed'] = false -> flag the targeted creature as such regardless of source INT --
-- the second true/false flag flips the result --

function GT_AI_ExtraCheck(source, target, extra)
	local sourceINT = source:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(source)
	if not aux["gt_AI_DetectableStates"] then
		aux["gt_AI_DetectableStates"] = {}
	end
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", sourceINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", sourceINT)]["DICE_SIZE"])
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	for condition, flags in pairs(extra) do -- ['mirrorImage'] = {true, true}
		local hash = sha.sha256(condition .. tostring(flags[2]))
		--
		if flags[1] then
			--
			if not GT_EvalConditional[condition](source, target, flags[2]) then
				for _, v in ipairs(aux["gt_AI_DetectableStates"]) do
					if v.mode == 3 then
						if v.hash == hash then
							if v.id == target.m_id then
								if m_gameTime >= v.expirationTime then
									-- timer expired: target not valid
									return false
								else
									-- timer already running: target valid
									goto continue
								end
							end
						end
					end
				end
				-- timer not set: target valid
				table.insert(aux["gt_AI_DetectableStates"],
					{
						["hash"] = hash,
						["id"] = target.m_id,
						["expirationTime"] = m_gameTime + 90 * math.random(dnum, dnum * dsize), -- 90 ticks ~ 1 round
						["mode"] = 3,
					}
				)
				--
				::continue::
			else
				-- condition detected: target valid
			end
		else
			if not GT_EvalConditional[condition](source, target, flags[2]) then
				return false
			end
		end
	end
	--
	return true -- all checks passed: target valid
end

