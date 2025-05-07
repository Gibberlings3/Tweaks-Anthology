--[[
+---------------------------------------------------------------------+
| cdtweaks, Give Every Class/Kit Four Weapon Slots                    |
+---------------------------------------------------------------------+
| Press and Hold ``Left Ctrl`` to access the extra quick weapon slots |
+---------------------------------------------------------------------+
--]]

local cdtweaks_GiveEveryClassKitFourWeaponSlots = {
	[1] = 2, -- Mage / Sorcerer
	[3] = 2, -- Cleric
	[4] = 2, -- Thief
	[5] = 2, -- Bard
	[6] = 3, -- Paladin
	[7] = 2, -- Fighter Mage
	[8] = 2, -- Fighter Cleric
	[9] = 2, -- Fighter Thief
	[10] = 2, -- Fighter Mage Thief
	[11] = 2, -- Druid
	[12] = 3, -- Ranger
	[13] = 2, -- Mage Thief
	[14] = 2, -- Cleric Mage
	[15] = 2, -- Cleric Thief
	[16] = 2, -- Fighter Druid
	[17] = 2, -- Fighter Mage Cleric
	[18] = 2, -- Cleric Ranger
	[20] = 3, -- Monk
	[21] = 2, -- Shaman
}

EEex_Key_AddPressedListener(function(key)

	local sprite = EEex_Sprite_GetSelected() -- CGameSprite
	if not sprite then
		return
	end

	local state = EEex_Actionbar_GetState()

	if sprite.m_typeAI.m_EnemyAlly == 2 then -- if [PC]
		if key == EEex_Key_GetFromName("Left Ctrl") then
			if cdtweaks_GiveEveryClassKitFourWeaponSlots[state] == 2 then
				-- replace weapon 1 and 2 with 3 and 4
				for i = 0, 11 do
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_1 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_3)
					end
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_2 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_4)
					end
				end
			elseif cdtweaks_GiveEveryClassKitFourWeaponSlots[state] == 3 then
				-- replace weapon 3 with 4
				for i = 0, 11 do
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_3 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_4)
					end
				end
			end
		end
	end

end)

EEex_Key_AddReleasedListener(function(key)

	local sprite = EEex_Sprite_GetSelected() -- CGameSprite
	if not sprite then
		return
	end

	local state = EEex_Actionbar_GetState()

	if sprite.m_typeAI.m_EnemyAlly == 2 then -- if [PC]
		if key == EEex_Key_GetFromName("Left Ctrl") then
			if cdtweaks_GiveEveryClassKitFourWeaponSlots[state] == 2 then
				-- replace weapon 3 and 4 with 1 and 2
				for i = 0, 11 do
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_3 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_1)
					end
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_4 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_2)
					end
				end
			elseif cdtweaks_GiveEveryClassKitFourWeaponSlots[state] == 3 then
				-- replace weapon 4 with 3
				for i = 0, 11 do
					if buttonArray:GetButtonType(i) == EEex_Actionbar_ButtonType.QUICK_WEAPON_4 then
						EEex_Actionbar_SetButton(i, EEex_Actionbar_ButtonType.QUICK_WEAPON_3)
					end
				end
			end
		end
	end

end)

