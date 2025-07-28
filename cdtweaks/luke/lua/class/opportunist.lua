--[[
+---------------------------------------------------------------------+
| cdtweaks, NWN-ish Opportunist class feat for chaotic-aligned Rogues |
+---------------------------------------------------------------------+
--]]

-- Apply Ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNOpportunist", 1)
		--
		local effectCodes = {
			{["op"] = 321, ["res"] = "%THIEF_OPPORTUNIST%"}, -- Remove effects by resource
			{["op"] = 73, ["p1"] = 2}, -- Attack damage bonus
			{["op"] = 278, ["p1"] = 2}, -- THAC0 bonus
			{["op"] = 142, ["p2"] = %feedback_icon%}, -- Display portrait icon
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["m_sourceRes"] = "%THIEF_OPPORTUNIST%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / flags
	local align = GT_Resource_SymbolToIDS["align"]
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local attackerSelectedWeapon = GT_Sprite_GetSelectedWeapon(sprite) -- Item_ability_st
	local attackerIsChaotic = GT_Sprite_CheckIDS(sprite, align["MASK_CHAOTIC"], 8)
	local attackerIsThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	local targetSprite = EEex_GameObject_Get(sprite.m_targetId) -- CGameSprite
	--
	local targetClassStr, targetSelectedWeapon
	if targetSprite then
		targetClassStr = GT_Resource_IDSToSymbol["class"][targetSprite.m_typeAI.m_Class]
		targetSelectedWeapon = GT_Sprite_GetSelectedWeapon(targetSprite) -- Item_ability_st
	end
	--
	local applyAbility = targetSprite and
		(attackerIsThiefAll and attackerIsChaotic and attackerSelectedWeapon["ability"].type == 1 and attackerSelectedWeapon["slot"] ~= 10) and
		(targetSelectedWeapon["ability"].type ~= 1 or (targetClassStr ~= "MONK" and targetSelectedWeapon["slot"] == 10))
	--
	if sprite:getLocalInt("gtNWNOpportunist") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNOpportunist", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%THIEF_OPPORTUNIST%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

