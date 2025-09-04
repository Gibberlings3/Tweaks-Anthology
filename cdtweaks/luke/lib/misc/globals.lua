--[[
+---------------------------------------------------------+
| For use with ``EEex_Opcode_AddListsResolvedListener()`` |
+---------------------------------------------------------+
| Kit active abilities should not be granted too early    |
+---------------------------------------------------------+
--]]

GT_Globals_IsChargenOrStartMenu = {
	['START'] = true,
	--
	['CHARGEN'] = true,
	['CHARGEN_GENDER'] = true,
	['CHARGEN_PORTRAIT'] = true,
	['CHARGEN_RACE'] = true,
	['CHARGEN_CLASS'] = true,
	['CHARGEN_KIT'] = true,
	['CHARGEN_ALIGNMENT'] = true,
	['CHARGEN_ABILITIES'] = true,
	['CHARGEN_PROFICIENCIES'] = true,
	['CHARGEN_CHOOSE_SPELLS'] = true,
	['CHARGEN_MEMORIZE_MAGE'] = true,
	['CHARGEN_MEMORIZE_PRIEST'] = true,
	['CHARGEN_CUSTOMSOUNDS'] = true,
	['CHARGEN_HATEDRACE'] = true,
	['CHARGEN_NAME'] = true,
	['CHARGEN_BIO'] = true,
	['CHARGEN_IMPORT'] = true,
	['CHARGEN_EXPORT'] = true,
	['CHARGEN_DUALCLASS'] = true,
	['CHARGEN_DIFFICULTY'] = true,
	['CHARGEN_HIGH_LEVEL_ABILITIES'] = true,
}

--[[
+---------------------------+
| Class To Weapon Slots Map |
+---------------------------+
--]]

GT_Globals_ClassToWeaponSlotsMap = {
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

