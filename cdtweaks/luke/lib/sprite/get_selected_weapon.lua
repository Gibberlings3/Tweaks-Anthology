-- get currently selected weapon (resref, slot, Item_Header_st, Item_ability_st) --

function GT_Sprite_GetSelectedWeapon(sprite)
	local equipment = sprite.m_equipment -- CGameSpriteEquipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	--
	return {
		["resref"] = selectedWeapon.pRes.resref:get(),
		["slot"] = equipment.m_selectedWeapon,
		["header"] = selectedWeapon.pRes.pHeader, -- Item_Header_st
		["ability"] = EEex_Resource_GetItemAbility(selectedWeapon.pRes.pHeader, equipment.m_selectedWeaponAbility), -- Item_ability_st
		["weapon"] = selectedWeapon, -- CItem
		["launcher"] = sprite:getLauncher(selectedWeapon:getAbility(equipment.m_selectedWeaponAbility)), -- CItem
		["launcherSlot"] = select(2, EEex_Sprite_GetLauncher(sprite, selectedWeapon:getAbility(equipment.m_selectedWeaponAbility))) -- int
	}
end

