--[[
+---------------------------------------+
| cdtweaks, instant troll coma mechanic |
+---------------------------------------+
--]]

-- Instantly put down trolls (and possibly some other creatures, such as SoD wolves...?) when less than 1 HP --

local cdtweaks_InstantTrollComa_ResRef = {
	-- game -> itm => spl
	[0] = {["TROLLREG"] = "TROLLREG"}, -- BGEE
	[1] = {["TROLLREG"] = "TROLLREG", ["CDTORGAL"] = "CDTORGAL"}, -- BG2EE
	[2] = {["REG1HP2"] = "CDIWDTR1"} -- IWDEE
}

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- Check creature's items
	local resref = ""
	local hasItemEquiped
	--
	for k, v in pairs(cdtweaks_InstantTrollComa_ResRef) do
		if engine_mode == k then
			for itm, spl in pairs(v) do
				hasItemEquiped = EEex_Trigger_ParseConditionalString(string.format('HasItemEquiped("%s",Myself)', itm))
				if hasItemEquiped:evalConditionalAsAIBase(sprite) then
					resref = spl
					goto continue
				end
			end
			break
		end
	end
	--
	::continue::
	if resref ~= "" and sprite.m_nLastDamageTaken >= sprite.m_baseStats.m_hitPoints and sprite:getLocalInt("gttrlslp") == 0 then
		sprite:setLocalInt("gttrlslp", 1)
		sprite.m_nLastDamageTaken = 0 -- should prevent infinite loop
		--
		sprite:applyEffect({
			["effectID"] = 146, -- cast spl
			["dwFlags"] = 1, -- instant / ignore level
			["res"] = resref,
			["noSave"] = true,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	--
	hasItemEquiped:free()
end)
