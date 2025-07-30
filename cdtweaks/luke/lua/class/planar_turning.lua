--[[
+----------------------------------------------------------------------+
| cdtweaks, NWN-ish Planar Turning class feat for Paladins and Clerics |
+----------------------------------------------------------------------+
--]]

-- Check if turning undead --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual turning
	local turnPlanarMode = function()
		sprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["dwFlags"] = 1, -- instant / ignore level
			["res"] = "%PRIEST_PLANAR_TURNING%", -- SPL file
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- turn undead lvl 21+; wis 17+, cha 17+; paladin or cleric
	local spriteWIS = sprite.m_derivedStats.m_nWIS
	local spriteCHR = sprite.m_derivedStats.m_nCHR
	--
	local class = GT_Resource_SymbolToIDS["class"]
	local isPaladinAll = GT_Sprite_CheckIDS(sprite, class["PALADIN_ALL"], 5, true)
	local isClericAll = GT_Sprite_CheckIDS(sprite, class["CLERIC_ALL"], 5)
	--
	local spriteTurnUndeadLevel = sprite.m_derivedStats.m_nTurnUndeadLevel
	-- Check if the creature is turning undead
	local turnUndeadMode = EEex_Sprite_GetModalState(sprite) == 4 and EEex_Sprite_GetModalTimer(sprite) == 0
	--
	if (isPaladinAll or isClericAll) and turnUndeadMode and spriteTurnUndeadLevel >= 21 and spriteWIS >= 17 and spriteCHR >= 17 then
		turnPlanarMode()
	end
end)

-- Core function --

function %PRIEST_PLANAR_TURNING%(CGameEffect, CGameSprite)
	local parentResRef = CGameEffect.m_sourceRes:get()
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	local align = GT_Resource_SymbolToIDS["align"]
	local isEvil = GT_Sprite_CheckIDS(sourceSprite, align["MASK_EVIL"], 8)
	--
	local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
	local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local targetRaceStr = GT_Resource_IDSToSymbol["race"][CGameSprite.m_typeAI.m_Race]
	--
	local roll = math.random(0, 3) -- engine: ((int)((rand() & 0x7fff) << 2) >> 0xf) => generates a random number, keeps its lower 15 bits, multiplies by 2^2, divides by 2^15
	--
	local effectCodes = {}
	--
	if targetRaceStr == "DEMONIC" or targetRaceStr == "MEPHIT" or targetRaceStr == "IMP" or targetRaceStr == "ELEMENTAL" or targetRaceStr == "SALAMANDER" or targetRaceStr == "SOLAR" or targetRaceStr == "ANTISOLAR" or targetRaceStr == "DARKPLANATAR" or targetRaceStr == "PLANATAR" or targetRaceStr == "GENIE" then -- if extraplanar ...
		if sourceActiveStats.m_nTurnUndeadLevel < (targetActiveStats.m_nLevel1 + roll) + 5 then
			if sourceActiveStats.m_nTurnUndeadLevel >= (targetActiveStats.m_nLevel1 + roll) then -- turn
				effectCodes = {
					{["op"] = 174, ["res"] = "ACT_06"}, -- play sound
					{["op"] = 141, ["p2"] = 24}, -- lighting effects (invocation air)
					{["op"] = 321, ["res"] = parentResRef}, -- remove effects by resource
					{["op"] = 24, ["p2"] = 1, ["dur"] = 60}, -- panic (bypass immunity)
					{["op"] = 142, ["p2"] = 36, ["dur"] = 60}, -- icon: panic
					{["op"] = 139, ["p1"] = %feedback_strref%}, -- feedback string
				}
			end
		else -- destroy or take control
			if isEvil then -- take control
				effectCodes = {
					{["op"] = 174, ["res"] = "ACT_06"}, -- play sound
					{["op"] = 141, ["p2"] = 24}, -- lighting effects (invocation air)
					{["op"] = 321, ["res"] = parentResRef}, -- remove effects by resource
					{["op"] = 241, ["p2"] = 4, ["dur"] = 60}, -- control creature (charm type: controlled)
				}
			else -- destroy
				effectCodes = {
					{["op"] = 174, ["res"] = "ACT_06"}, -- play sound
					{["op"] = 141, ["p2"] = 24}, -- lighting effects (invocation air)
					{["op"] = 13, ["p2"] = 0x4, ["tmg"] = 4}, -- kill (normal death)
				}
			end
		end
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["duration"] = attributes["dur"] or 0,
				["durationType"] = attributes["tmg"] or 0,
				["noSave"] = true,
				["m_sourceRes"] = parentResRef,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
