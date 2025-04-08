--[[
+-----------------------+
| Level up the creature |
+-----------------------+
--]]

function GT_AnimalCompanion_LevelUp()
	local summonerID = EEex_LuaAction_Object.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	local summonerClass = summonerSprite.m_typeAI.m_Class
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local summonerBaseLevel = -1
	local creatureBaseLevel = EEex_LuaAction_Object.m_baseStats.m_level1
	--
	if summonerClass == class["CLERIC_RANGER"] then
		summonerBaseLevel = summonerSprite.m_baseStats.m_level2
	else
		summonerBaseLevel = summonerSprite.m_baseStats.m_level1
	end
	-- Update creature's level
	EEex_LuaAction_Object:applyEffect({
		["effectID"] = 96, -- level change
		["durationType"] = 1,
		["dwFlags"] = 1, -- set
		["effectAmount"] = summonerBaseLevel,
		["noSave"] = true,
		["sourceID"] = EEex_LuaAction_Object.m_id,
		["sourceTarget"] = EEex_LuaAction_Object.m_id,
	})
	-- Update creature's saves
	local savewar = GT_Resource_2DA["savewar"]
	local effectCodes = {
		{["op"] = 33, ["p1"] = tonumber(savewar["DEATH"][string.format("%s", summonerBaseLevel)])}, -- save vs. death
		{["op"] = 34, ["p1"] = tonumber(savewar["WANDS"][string.format("%s", summonerBaseLevel)])}, -- save vs. wands
		{["op"] = 35, ["p1"] = tonumber(savewar["POLY"][string.format("%s", summonerBaseLevel)])}, -- save vs. polymorph
		{["op"] = 36, ["p1"] = tonumber(savewar["BREATH"][string.format("%s", summonerBaseLevel)])}, -- save vs. breath
		{["op"] = 37, ["p1"] = tonumber(savewar["SPELL"][string.format("%s", summonerBaseLevel)])}, -- save vs. spell
	}
	--
	for _, attributes in ipairs(effectCodes) do
		EEex_LuaAction_Object:applyEffect({
			["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
			["durationType"] = 1,
			["dwFlags"] = 1, -- set
			["effectAmount"] = attributes["p1"] or 0,
			["noSave"] = true,
			["sourceID"] = EEex_LuaAction_Object.m_id,
			["sourceTarget"] = EEex_LuaAction_Object.m_id,
		})
	end
	-- Update HP
	EEex_LuaAction_Object:applyEffect({
		["effectID"] = 18, -- max HP bonus
		["durationType"] = 1,
		["dwFlags"] = 4, -- set, don't update current HP
		["effectAmount"] = summonerSprite.m_baseStats.m_maxHitPointsBase,
		["noSave"] = true,
		["sourceID"] = EEex_LuaAction_Object.m_id,
		["sourceTarget"] = EEex_LuaAction_Object.m_id,
	})
	-- Update THAC0
	local thac0 = GT_Resource_2DA["thac0"]
	EEex_LuaAction_Object:applyEffect({
		["effectID"] = 54, -- base THAC0 bonus
		["durationType"] = 1,
		["dwFlags"] = 1, -- set
		["effectAmount"] = tonumber(thac0["FIGHTER"][string.format("%s", summonerBaseLevel)]),
		["noSave"] = true,
		["sourceID"] = EEex_LuaAction_Object.m_id,
		["sourceTarget"] = EEex_LuaAction_Object.m_id,
	})
	-- Upgrade creature weapon
	local items = EEex_LuaAction_Object.m_equipment.m_items -- Array<CItem*,39>
	local weaponUpgrades = {
		["gtAnmlCompBear"] = {"0B", "0C", "0D", "0E"},
		["gtAnmlCompBeetle"] = {"1B", "1C", "1D", "1E"},
		["gtAnmlCompBoar"] = {"2B", "2C", "2D", "2E"},
		["gtAnmlCompFalcon"] = {"3B", "3C", "3D", "3E"},
		["gtAnmlCompLeopard"] = {"4B", "4C", "4D", "4E"},
		["gtAnmlCompSnake"] = {"5B", "5C", "5D", "5E"},
		["gtAnmlCompSpider"] = {"6B", "6C", "6D", "6E"},
		["gtAnmlCompWolf"] = {"7B", "7C", "7D", "7E"},
	}
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			local newItemResRef = item.pRes.resref:get()
			--
			if (summonerBaseLevel >= 5 and summonerBaseLevel < 9) then
				newItemResRef = "GTACOM" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][1]
			elseif (summonerBaseLevel >= 10 and summonerBaseLevel < 14) then
				newItemResRef = "GTACOM" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][2]
			elseif (summonerBaseLevel >= 15 and summonerBaseLevel < 19) then
				newItemResRef = "GTACOM" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][3]
			elseif (summonerBaseLevel >= 20) then
				newItemResRef = "GTACOM" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][4]
			end
			--
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 143, -- Create item in slot
				["durationType"] = 1,
				["effectAmount"] = i, -- slot
				["res"] = newItemResRef,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
			--
			local XEquipItem = EEex_Action_ParseResponseString(string.format('XEquipItem("%s",Myself,%d,EQUIP)', newItemResRef, i))
			XEquipItem:executeResponseAsAIBaseInstantly(EEex_LuaAction_Object) -- "XEquipItem()" is actually instant (even if not listed in "INSTANT.IDS")... It never returns ``CGameAIBase::ACTION_NORMAL`` or ``CGameAIBase::ACTION_INTERRUPTABLE``... Feel free to use it with ``EEex_Action_ExecuteScriptFileResponseAsAIBaseInstantly()``...
			XEquipItem:free()
		end
	end
	-- Update AC
	for i = creatureBaseLevel + 1, summonerBaseLevel do
		if i % 5 == 0 then
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 0, -- AC bonus
				["durationType"] = 1,
				["dwFlags"] = 0x0, -- increment
				["effectAmount"] = 1,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
		end
	end
	-- Update creature's DEX
	if EEex_LuaAction_Object.m_scriptName:get() == "gtAnmlCompLeopard" then
		for i = creatureBaseLevel + 1, summonerBaseLevel do
			if i % 10 == 0 then
				EEex_LuaAction_Object:applyEffect({
					["effectID"] = 15, -- DEX bonus
					["durationType"] = 1,
					["dwFlags"] = 0x0, -- increment
					["effectAmount"] = 1,
					["noSave"] = true,
					["sourceID"] = EEex_LuaAction_Object.m_id,
					["sourceTarget"] = EEex_LuaAction_Object.m_id,
				})
			end
		end
	end
	-- Special abilities
	local specialAbilities = {
		["gtAnmlCompBeetle"] = nil,
		["gtAnmlCompBear"] = nil,
		["gtAnmlCompFalcon"] = nil,
		["gtAnmlCompSnake"] = "%INNATE_SNAKE_CHARM%",
		["gtAnmlCompLeopard"] = nil,
		["gtAnmlCompSpider"] = "%INNATE_SPIDER_WEB_TANGLE%",
		["gtAnmlCompWolf"] = "%INNATE_WINTER_WOLF_FROST_BREATH%",
		["gtAnmlCompBoar"] = "%INNATE_ANIMAL_FEROCITY%",
	}
	if specialAbilities[EEex_LuaAction_Object.m_scriptName:get()] then
		for i = creatureBaseLevel + 1, summonerBaseLevel do
			if i % 5 == 0 then
				EEex_LuaAction_Object:applyEffect({
					["effectID"] = 171, -- gain special ability
					["res"] = specialAbilities[EEex_LuaAction_Object.m_scriptName:get()],
					["noSave"] = true,
					["sourceID"] = EEex_LuaAction_Object.m_id,
					["sourceTarget"] = EEex_LuaAction_Object.m_id,
				})
			end
		end
	end
end
