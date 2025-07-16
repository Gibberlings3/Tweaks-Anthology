--[[
+-----------------------+
| Level up the creature |
+-----------------------+
--]]

function GT_NWN_AnmlComp_LevelUp()
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
	-- Update creature's racial enemy
	--EEex_LuaAction_Object.m_baseStats.m_hatedRace = summonerSprite.m_baseStats.m_hatedRace
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
	do
		local hpclass = GT_Resource_2DA["hpclass"]
		local hptbl = hpclass["BEAST_MASTER"]["TABLE"]
		--
		local data = EEex_Resource_Load2DA(hptbl)
		local nX, nY = data:getDimensions()
		nX = nX - 2
		nY = nY - 1
		--
		local m_maxHitPointsBase = 0
		for rowIndex = 0, nY do
			if tonumber(data:getRowLabel(rowIndex)) <= summonerBaseLevel then
				local sides = tonumber(data:getAtPoint(0, rowIndex))
				local rolls = tonumber(data:getAtPoint(1, rowIndex))
				local modifier = tonumber(data:getAtPoint(2, rowIndex))
				--
				m_maxHitPointsBase = m_maxHitPointsBase + (sides * rolls) + modifier
			end
		end
		--
		if creatureBaseLevel == 0 then
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 18, -- max HP bonus
				["durationType"] = 1,
				["dwFlags"] = 1, -- set, update current HP
				["effectAmount"] = m_maxHitPointsBase,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
		else
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 18, -- max HP bonus
				["durationType"] = 1,
				["dwFlags"] = 4, -- set, don't update current HP
				["effectAmount"] = m_maxHitPointsBase,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
		end
		--
		data:free()
	end
	-- Update THAC0
	local thac0 = GT_Resource_2DA["thac0"]
	EEex_LuaAction_Object:applyEffect({
		["effectID"] = 54, -- base THAC0 bonus
		["durationType"] = 1,
		["dwFlags"] = 1, -- set
		["effectAmount"] = tonumber(thac0["RANGER"][string.format("%s", summonerBaseLevel)]),
		["noSave"] = true,
		["sourceID"] = EEex_LuaAction_Object.m_id,
		["sourceTarget"] = EEex_LuaAction_Object.m_id,
	})
	-- Upgrade creature weapon
	local items = EEex_LuaAction_Object.m_equipment.m_items -- Array<CItem*,39>
	local weaponUpgrades = {
		["gtNWNAnmlCompBear"] = {"01B", "01C", "01D", "01E"},
		["gtNWNAnmlCompBeetle"] = {"02B", "02C", "02D", "02E"},
		["gtNWNAnmlCompBoar"] = {"03B", "03C", "03D", "03E"},
		["gtNWNAnmlCompFalcon"] = {"04B", "04C", "04D", "04E"},
		["gtNWNAnmlCompLeopard"] = {"05B", "05C", "05D", "05E"},
		["gtNWNAnmlCompSnake"] = {"06B", "06C", "06D", "06E"},
		["gtNWNAnmlCompSpider"] = {"07B", "07C", "07D", "07E"},
		["gtNWNAnmlCompWolf"] = {"08B", "08C", "08D", "08E"},
	}
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			local newItemResRef = item.pRes.resref:get()
			--
			if (summonerBaseLevel >= 5 and summonerBaseLevel < 9) then
				newItemResRef = "GTPET" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][1]
			elseif (summonerBaseLevel >= 10 and summonerBaseLevel < 14) then
				newItemResRef = "GTPET" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][2]
			elseif (summonerBaseLevel >= 15 and summonerBaseLevel < 19) then
				newItemResRef = "GTPET" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][3]
			elseif (summonerBaseLevel >= 20) then
				newItemResRef = "GTPET" .. weaponUpgrades[EEex_LuaAction_Object.m_scriptName:get()][4]
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
	-- Update creature's DEX / HiS / MS
	if EEex_LuaAction_Object.m_scriptName:get() == "gtNWNAnmlCompLeopard" then
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
			--
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 275, -- HiS bonus
				["durationType"] = 1,
				["dwFlags"] = 0x0, -- increment
				["effectAmount"] = 5,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 59, -- MS bonus
				["durationType"] = 1,
				["dwFlags"] = 0x0, -- increment
				["effectAmount"] = 5,
				["noSave"] = true,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
		end
	end
	-- Special abilities
	local specialAbilities = {
		["gtNWNAnmlCompBeetle"] = nil,
		["gtNWNAnmlCompBear"] = nil,
		["gtNWNAnmlCompFalcon"] = nil,
		["gtNWNAnmlCompSnake"] = "%INNATE_SNAKE_GRASP%",
		["gtNWNAnmlCompLeopard"] = nil,
		["gtNWNAnmlCompSpider"] = "%INNATE_SPIDER_WEB_TANGLE%",
		["gtNWNAnmlCompWolf"] = "%INNATE_WINTER_WOLF_FROST_BREATH%",
		["gtNWNAnmlCompBoar"] = "%INNATE_ANIMAL_FEROCITY%",
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
