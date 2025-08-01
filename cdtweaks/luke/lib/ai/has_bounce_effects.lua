-- check if the target can bounce the specified level/projectile/school/sectype/resref/opcode(s) --

function GT_AI_HasBounceEffects(source, target, level, projectileType, school, sectype, resref, opcodes, flags)
	local sourceINT = source:getActiveStats().m_nINT
	--
	local aux = EEex_GetUDAux(source)
	if not aux["gt_AI_DetectableStates"] then
		aux["gt_AI_DetectableStates"] = {}
	end
	--
	local m_gameTime = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_worldTime.m_gameTime
	--
	local gtintmod = GT_Resource_2DA["gtintmod"]
	local dnum = tonumber(gtintmod[string.format("%s", sourceINT)]["DICE_NUM"])
	local dsize = tonumber(gtintmod[string.format("%s", sourceINT)]["DICE_SIZE"])
	--
	local toReturn = false
	--
	local hash = sha.sha256(tostring(level) .. tostring(projectileType) .. tostring(school) .. tostring(sectype) .. resref .. (opcodes and GT_Utility_ArrayToString(opcodes) or "nil") .. tostring(flags))
	--
	local found = GT_Sprite_HasBounceEffects(target, level, projectileType, school, sectype, resref, opcodes, flags)
	--
	if found then
		for _, v in ipairs(aux["gt_AI_DetectableStates"]) do
			if v.mode == 1 then
				if v.hash == hash then
					if v.id == target.m_id then
						if m_gameTime >= v.expirationTime then
							-- timer expired: target not valid
						else
							-- timer already running: target valid
							toReturn = true
						end
						--
						goto continue
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
				["mode"] = 1,
			}
		)
		--
		toReturn = true
	else
		toReturn = true -- immunity not detected: target valid
	end
	--
	::continue::
	return toReturn
end

