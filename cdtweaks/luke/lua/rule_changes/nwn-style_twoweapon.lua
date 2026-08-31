--[[
+---------------------------------------+
| cdtweaks, NWN-ish Two-Weapon Fighting |
+---------------------------------------+
--]]

-- When dual-wielding, the off-hand weapon gets only half (rounded down) of a positive strength modifier as bonus damage --
-- If the strength modifier is negative, the full penalty (not half) will apply --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and sprite.m_pArea) then
		return
	end
	-- internal function that applies the actual penalty
	local apply = function(value)
		-- Mark the creature as 'penalty applied'
		sprite:setLocalInt("gtNWNTwoWeaponSTRBonus", value)
		--
		local effectCodes = {
			{["op"] = 0x141, ["res"] = "GTRULE05"}, -- Remove effects by resource (321)
			{["op"] = 0x49, ["spec"] = 0x2, ["p1"] = (math.ceil(value * 0.5)) * -1}, -- Attack damage bonus (73)
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["special"] = attributes["spec"] or 0,
				["effectAmount"] = attributes["p1"] or 0,
				["m_sourceRes"] = "GTRULE05",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
				["noSave"] = true, -- just in case
			})
		end
	end
	-- Check creature's active weapon style
	local id = EEex_Sprite_GetWeaponStyle(sprite)
	-- PROFICIENCY2WEAPON (114) and positive strength modifier
	local activeStats = sprite:getActiveStats()
	local strMod = tonumber(EEex_Resource_2DA("STRMOD", activeStats.m_nSTR, "DAMAGE")) + tonumber(EEex_Resource_2DA("STRMODEX", activeStats.m_nSTRExtra, "DAMAGE"))
	--
	local applyPenalty = (id == EEex_Resource_SymbolToIDS("WPROF", "PROFICIENCY2WEAPON")) and (strMod > 0)
	--
	if sprite:getLocalInt("gtNWNTwoWeaponSTRBonus") == 0 then
		if applyPenalty then
			apply(strMod)
		end
	else
		if applyPenalty then
			if strMod ~= sprite:getLocalInt("gtNWNTwoWeaponSTRBonus") then
				apply(strMod)
			else
				-- Do nothing
			end
		else
			-- Mark the creature as 'penalty removed'
			sprite:setLocalInt("gtNWNTwoWeaponSTRBonus", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE05",
				["noSave"] = true, -- just in case
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- The character with this feat is able to get a second off-hand attack (at a penalty of -5 to his attack roll) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and sprite.m_pArea) then
		return
	end
	-- internal function that applies the actual second off-hand attack
	local apply = function(value, string)
		-- Mark the creature as 'feat applied'
		sprite:setLocalString("gtNWNImprovedTwoWeapon", string)
		--
		local effectCodes = {
			{["op"] = 0x141, ["res"] = "GTRULE06"}, -- Remove effects by resource (321)
			{["op"] = 0x156, ["spec"] = 0x1, ["p1"] = value, ["p2"] = 5, ["p3"] = -5, ["res"] = string}, -- Override creature data (342)
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["special"] = attributes["spec"] or 0,
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["m_effectAmount2"] = attributes["p3"] or 0,
				["m_sourceRes"] = "GTRULE06",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
				["noSave"] = true, -- just in case
			})
		end
	end
	-- Check creature's active weapon style and rank
	local id, rank, _ = EEex_Sprite_GetWeaponStyle(sprite)
	-- PROFICIENCY2WEAPON (114) +++
	local activeStats = sprite:getActiveStats()
	local slot = activeStats.m_nNumberOfAttacks - 1
	slot = math.max(0, math.min(4, slot))
	local bmpResRef = "GTRNDBS" .. tostring(slot + 1)
	--
	local applyFeat = (id == EEex_Resource_SymbolToIDS("WPROF", "PROFICIENCY2WEAPON")) and (rank >= 3)
	--
	if sprite:getLocalString("gtNWNImprovedTwoWeapon") == "" then
		if applyFeat then
			apply(slot, bmpResRef)
		end
	else
		if applyFeat then
			if bmpResRef ~= sprite:getLocalString("gtNWNImprovedTwoWeapon") then
				apply(slot, bmpResRef)
			else
				-- Do nothing
			end
		else
			-- Mark the creature as 'penalty removed'
			sprite:setLocalString("gtNWNImprovedTwoWeapon", "")
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE06",
				["noSave"] = true, -- just in case
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- If the off-hand weapon is light, further reduce the penalty for both the primary and off-hand by 2 --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not (EEex_GameObject_IsSprite(sprite) and sprite.m_pArea) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("gtNWNTwoWeaponLight", 1)
		--
		local effectCodes = {
			{["op"] = 0x141, ["res"] = "GTRULE07"}, -- Remove effects by resource (321)
			{["op"] = 0x116, ["p1"] = 2}, -- THAC0 bonus (278)
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 9,
				["res"] = attributes["res"] or "",
				["effectAmount"] = attributes["p1"] or 0,
				["m_sourceRes"] = "GTRULE07",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
				["noSave"] = true, -- just in case
			})
		end
	end
	-- Check creature's active weapon style and off-hand weapon
	local id = EEex_Sprite_GetWeaponStyle(sprite)
	local items = sprite.m_equipment.m_items -- Array<CItem*,39>
	local offHand = items:get(9) -- CItem
	local offHandRes = offHand and offHand.pRes.resref:get() or ""
	local offHandHeader = offHand and offHand.pRes.pHeader or nil -- Item_Header_st
	local offHandType = offHandHeader and offHandHeader.itemType or -1
	local unusuallyLargeWeapons = {
		["BDBONE02"] = true, -- Ettin Club +1 (SoD)
	}
	local isOffHandLight = offHandHeader and (offHandType == EEex_Resource_SymbolToIDS("ITEMCAT", "DAGGER") or offHandType == EEex_Resource_SymbolToIDS("ITEMCAT", "SMSWORD") or offHandType == EEex_Resource_SymbolToIDS("ITEMCAT", "MACE")) or false
	--
	local applyBonus = (id == EEex_Resource_SymbolToIDS("WPROF", "PROFICIENCY2WEAPON")) and (isOffHandLight) and (not unusuallyLargeWeapons[offHandRes])
	--
	if sprite:getLocalInt("gtNWNTwoWeaponLight") == 0 then
		if applyBonus then
			apply()
		end
	else
		if applyBonus then
			-- Do nothing
		else
			-- Mark the creature as 'penalty removed'
			sprite:setLocalInt("gtNWNTwoWeaponLight", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE07",
				["noSave"] = true, -- just in case
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

