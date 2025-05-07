--[[
+-----------------------------------------------------------------+
| Make sure both the animal and its summoner are in the same area |
+-----------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) or not sprite.m_pArea then
		return
	end
	--
	local summoner = EEex_GameObject_Get(sprite.m_lSummonedBy.m_Instance) -- CGameSprite
	--
	local deathvarSources = {
		["gtAnmlCompWolf"] = true,
		["gtAnmlCompFalcon"] = true,
		["gtAnmlCompBear"] = true,
		["gtAnmlCompBoar"] = true,
		["gtAnmlCompLeopard"] = true,
		["gtAnmlCompSnake"] = true,
		["gtAnmlCompBeetle"] = true,
		["gtAnmlCompSpider"] = true,
	}
	--
	local m_scriptName = sprite.m_scriptName:get()
	--
	if deathvarSources[m_scriptName] then
		if not EEex_UDEqual(sprite.m_pArea, summoner.m_pArea) then
			sprite:applyEffect({
				["effectID"] = 186, -- move to area
				["sourceX"] = summoner.m_pos.x,
				["sourceY"] = summoner.m_pos.y,
				["targetX"] = summoner.m_pos.x,
				["targetY"] = summoner.m_pos.y,
				["res"] = summoner.m_pArea.m_resref:get(), -- ARE file
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
				["noSave"] = true,
			})
		end
	end
end)

