--[[
+------------------------------------------------------------------------------------------------------------------------------------------------------------+
| cdtweaks, "bank" XP when dualing a character (https://www.gibberlings3.net/forums/topic/28900-future-tweak-ideas-post-em-here/page/40/#findComment-352854) |
+------------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and GT_Sprite_IsPartyMember(sprite)) then
		return
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local m_flags = sprite.m_baseStats.m_flags
	local m_level1 = sprite.m_baseStats.m_level1
	local m_level2 = sprite.m_baseStats.m_level2
	local m_xp = sprite.m_baseStats.m_xp
	--
	local lvl = {m_level1, m_level2}
	--
	local originalClass
	if EEex_IsBitSet(m_flags, 0x3) then
		originalClass = "FIGHTER"
	elseif EEex_IsBitSet(m_flags, 0x4) then
		originalClass = "MAGE"
	elseif EEex_IsBitSet(m_flags, 0x5) then
		originalClass = "CLERIC"
	elseif EEex_IsBitSet(m_flags, 0x6) then
		originalClass = "THIEF"
	elseif EEex_IsBitSet(m_flags, 0x7) then
		originalClass = "DRUID"
	elseif EEex_IsBitSet(m_flags, 0x8) then
		originalClass = "RANGER"
	end
	--
	local mapping = {
		["FIGHTER_MAGE"] = {"FIGHTER", "MAGE"},
		["FIGHTER_CLERIC"] = {"FIGHTER", "CLERIC"},
		["FIGHTER_THIEF"] = {"FIGHTER", "THIEF"},
		["MAGE_THIEF"] = {"MAGE", "THIEF"},
		["CLERIC_MAGE"] = {"CLERIC", "MAGE"},
		["CLERIC_THIEF"] = {"CLERIC", "THIEF"},
		["FIGHTER_DRUID"] = {"FIGHTER", "DRUID"},
		["CLERIC_RANGER"] = {"CLERIC", "RANGER"},
	}
	--
	local xplevel = GT_Resource_2DA["xplevel"]
	--
	if sprite:getLocalInt("gtDualClassTweak") == 0 then
		if mapping[spriteClassStr] and originalClass then
			for k, v in ipairs(mapping[spriteClassStr]) do
				if v == originalClass then
					-- update var
					sprite:setLocalInt("gtDualClassTweak", 1)
					-- add XP
					sprite:applyEffect({
						["effectID"] = 0x68, -- XP bonus (104)
						["durationType"] = 1,
						["effectAmount"] = math.max(0, sprite:getLocalInt("gtDualClassStoredXP") - tonumber(xplevel[v][tostring(lvl[k])])),
						["noSave"] = true,
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
					--
					break
				end
			end
		elseif Infinity_GetCurrentScreenName() == "CHARGEN_DUALCLASS" then
			if sprite:getLocalInt("gtDualClassStoredXP") ~= m_xp then
				sprite:setLocalInt("gtDualClassStoredXP", m_xp)
			end
		end
	end
end)

