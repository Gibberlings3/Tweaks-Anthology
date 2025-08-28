-- get current critical hit / miss bonuses --

function GT_Sprite_GetCriticalModifiers(sprite, offHand)
	if offHand == nil or type(offHand) ~= "boolean" then
		offHand = false
	end
	--
	local m_cCriticalEntryList = sprite:getActiveStats().m_cCriticalEntryList
	--
	local criticalHitModifier = 0
	local criticalMissModifier = 0
	--
	local selectedWeapon = GT_Sprite_GetSelectedWeapon(sprite)
	local attackType = selectedWeapon["ability"].type
	local slot = selectedWeapon["slot"]
	--
	if selectedWeapon["launcher"] then
		local items = sprite.m_equipment.m_items -- Array<CItem*,39>
		--
		for i = 34, 38 do -- also check the magical weapon slot
			local item = items:get(i) -- CItem
			--
			if item then -- sanity check
				if EEex_UDEqual(item, selectedWeapon["launcher"]) then
					slot = i
					break
				end
			end
		end
	end
	--
	if offHand then
		local items = sprite.m_equipment.m_items -- Array<CItem*,39>
		local item = items:get(9) -- CItem
		--
		slot = 9
		attackType = -1
		--
		if item then -- sanity check
			local pHeader = item.pRes.pHeader -- Item_Header_st
			if EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType) ~= "SHIELD" then
				attackType = item:getAbility(0).type -- Item_ability_st
			end
		end
	end
	--
	EEex_Utility_IterateCPtrList(m_cCriticalEntryList, function(entry)
		if entry.m_res:get() == "" then
			if entry.m_hitOrMiss == 0 then -- op301/341 (critical hit)
				if entry.m_attackType == 0 or entry.m_attackType == attackType then
					if entry.m_slot == -1 or entry.m_slot == slot then
						criticalHitModifier = criticalHitModifier + entry.m_bonus
					end
				end
			elseif entry.m_hitOrMiss == 1 then -- op361/362 (critical miss)
				if entry.m_attackType == 0 or entry.m_attackType == attackType then
					if entry.m_slot == -1 or entry.m_slot == slot then
						criticalMissModifier = criticalMissModifier + entry.m_bonus
					end
				end
			end
		end
	end)
	--
	return criticalHitModifier, criticalMissModifier
end

