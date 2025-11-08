--[[
+---------------------------------------------------------+
| cdtweaks, Force the AI to cast AoE spells on the ground |
+---------------------------------------------------------+
--]]

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)

	local actionSources = {
		-- spell
		[31] = 95, -- Spell() -> SpellPoint()
		[113] = 114, -- ForceSpell() -> ForceSpellPoint()
		[191] = 192, -- SpellNoDec() -> SpellPointNoDec()
		[181] = 337, -- ReallyForceSpell() -> ReallyForceSpellPoint()
		[318] = 319, -- ForceSpellRange() -> ForceSpellPointRange()
		-- item
		[34] = 97, -- UseItem() / UseItemAbility() / UseItemSlot() / UseItemSlotAbility() -> UseItemPoint() / UseItemPointSlot()
	}

	if actionSources[action.m_actionID] then -- sanity check

		local res, ext, casterLevel, abilityIndex
		local target = EEex_GameObject_Get(action.m_acteeID.m_Instance)

		if action.m_actionID == 34 then -- UseItem*()
			res = action.m_string1.m_pchData:get()
			--
			if res == "" then
				local items = sprite.m_equipment.m_items -- Array<CItem*,39>
				local item = items:get(action.m_specificID) -- CItem
				if item then -- sanity check
					res = item.pRes.resref:get()
				end
			end
			--
			ext = "itm"
			--
			abilityIndex = action.m_specificID2
		else -- Spell*()
			res = action.m_string1.m_pchData:get()
			--
			if res == "" then
				res = GT_Utility_DecodeSpell(action.m_specificID)
				casterLevel = EEex_Sprite_GetCasterLevelForSpell(sprite, res, true)
			end
			--
			ext = "spl"
			--
			if not casterLevel then
				casterLevel = action.m_specificID <= 0 and EEex_Sprite_GetCasterLevelForSpell(sprite, res, true) or action.m_specificID
			end
		end

		if ext and res and target and (casterLevel or abilityIndex) then -- sanity check

			-- check if the spell/item is AoE
			local pHeader = EEex_Resource_Demand(res, ext)
			if pHeader then -- sanity check
				local pAbility = ext == "itm" and EEex_Resource_GetItemAbility(pHeader, abilityIndex) or EEex_Resource_GetSpellAbilityForLevel(pHeader, casterLevel)
				if pAbility then -- sanity check
					if pAbility.actionType == 4 then -- AoE
						-- proceed to change action to Point version
						action.m_actionID = actionSources[action.m_actionID]
						action.m_dest.x = target.m_pos.x
						action.m_dest.y = target.m_pos.y
					end
				end
			end
		end

	end
end)

