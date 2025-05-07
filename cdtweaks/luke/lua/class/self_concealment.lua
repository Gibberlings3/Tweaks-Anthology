--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Self Concealment class feat for Monks |
+---------------------------------------------------------+
--]]

local cdtweaks_MonkSelfConcealment_FeedbackStrrefs = {
	[10] = %strref_10%,
	[20] = %strref_20%,
	[30] = %strref_30%,
	[40] = %strref_40%,
	[50] = %strref_50%,
}

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat (translucency + icon)
	local apply = function(percentage)
		-- Update tracking var
		sprite:setLocalInt("gtMonkSelfConcealment", percentage)
		--
		local effectCodes = {
			{["op"] = 321, ["res"] = "%MONK_SELF_CONCEALMENT%"}, -- Remove effects by resource
			{["op"] = 66, ["p1"] = math.floor((percentage / 100) * 255)}, -- Translucency
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
				["m_sourceRes"] = "%MONK_SELF_CONCEALMENT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / level / dexterity
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteDEX = sprite.m_derivedStats.m_nDEX
	-- compute concealment percentage
	local percentage = math.min(math.floor((spriteLevel1 - 10) / 5) + 1, 5) * 10 -- from 10 to 50
	-- lvl 10+ monks; 16+ DEX
	local applyAbility = spriteClassStr == "MONK" and spriteLevel1 >= 10 and spriteDEX >= 16
	--
	if sprite:getLocalInt("gtMonkSelfConcealment") == 0 then
		if applyAbility then
			apply(percentage)
		end
	else
		if applyAbility then
			-- check if ``percentage`` has changed since the last application
			if sprite:getLocalInt("gtMonkSelfConcealment") ~= percentage then
				apply(percentage)
			end
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtMonkSelfConcealment", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%MONK_SELF_CONCEALMENT%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core listener --

EEex_Sprite_AddBlockWeaponHitListener(function(args)
	local targetSprite = args.targetSprite -- CGameSprite
	--
	if math.random(100) <= targetSprite:getLocalInt("gtMonkSelfConcealment") then -- 1d100 roll
		-- display some feedback
		targetSprite:applyEffect({
			["effectID"] = 139, -- Display string
			["effectAmount"] = cdtweaks_MonkSelfConcealment_FeedbackStrrefs[targetSprite:getLocalInt("gtMonkSelfConcealment")],
			["sourceID"] = targetSprite.m_id,
			["sourceTarget"] = targetSprite.m_id,
		})
		-- block base weapon damage + on-hit effects (if any)
		return true
	end
end)
