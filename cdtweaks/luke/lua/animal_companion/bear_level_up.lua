-- cdtweaks, Animal Companion (bear): level up the creature --

function GT_AnimalCompanion_Bear_LevelUp()
	local summonerID = EEex_LuaAction_Object.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	--
	local summonerClass = summonerSprite.m_typeAI.m_Class
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local summonerLevel = -1
	local creatureLevel = EEex_LuaAction_Object.m_baseStats.m_level1
	--
	if summonerClass == class["CLERIC_RANGER"] then
		summonerLevel = summonerSprite.m_baseStats.m_level2
	else
		summonerLevel = summonerSprite.m_baseStats.m_level1
	end
	-- Update creature's level
	EEex_LuaAction_Object.m_baseStats.m_level1 = summonerLevel
	-- Update creature's saves
	local savewar = GT_Resource_2DA["savewar"]
	EEex_LuaAction_Object.m_baseStats.m_saveVSDeathBase = tonumber(savewar["DEATH"][string.format("%s", summonerLevel)])
	EEex_LuaAction_Object.m_baseStats.m_saveVSWandsBase = tonumber(savewar["WANDS"][string.format("%s", summonerLevel)])
	EEex_LuaAction_Object.m_baseStats.m_saveVSPolyBase = tonumber(savewar["POLY"][string.format("%s", summonerLevel)])
	EEex_LuaAction_Object.m_baseStats.m_saveVSBreathBase = tonumber(savewar["BREATH"][string.format("%s", summonerLevel)])
	EEex_LuaAction_Object.m_baseStats.m_saveVSSpellBase = tonumber(savewar["SPELL"][string.format("%s", summonerLevel)])
	-- Update HP
	EEex_LuaAction_Object.m_baseStats.m_hitPoints = summonerSprite.m_baseStats.m_hitPoints
	EEex_LuaAction_Object.m_baseStats.m_maxHitPointsBase = summonerSprite.m_baseStats.m_maxHitPointsBase
	-- Update THAC0
	local thac0 = GT_Resource_2DA["thac0"]
	EEex_LuaAction_Object.m_baseStats.m_toHitArmorClass0Base = tonumber(thac0["FIGHTER"][string.format("%s", summonerLevel)])
	-- Update creature weapon
	local items = EEex_LuaAction_Object.m_equipment.m_items -- Array<CItem*,39>
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			local newItemResRef = item.pRes.resref:get()
			--
			if (summonerLevel >= 5 and summonerLevel < 9) then
				newItemResRef = "GTACP01B"
			elseif (summonerLevel >= 10 and summonerLevel < 14) then
				newItemResRef = "GTACP01C"
			elseif (summonerLevel >= 15 and summonerLevel < 19) then
				newItemResRef = "GTACP01D"
			elseif (summonerLevel >= 20) then
				newItemResRef = "GTACP01E"
			end
			--
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 143, -- Create item in slot
				["durationType"] = 1,
				["effectAmount"] = i, -- slot
				["res"] = newItemResRef,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
			--
			local equipItem = EEex_Action_ParseResponseString(string.format('XEquipItem("%s",Myself,%d,EQUIP)', newItemResRef, i))
			equipItem:executeResponseAsAIBaseInstantly(EEex_LuaAction_Object) -- "XEquipItem()" is actually instant (even if not listed in "INSTANT.IDS")... It never returns ``CGameAIBase::ACTION_NORMAL`` or ``CGameAIBase::ACTION_INTERRUPTABLE``... Feel free to use it with ``EEex_Action_ExecuteScriptFileResponseAsAIBaseInstantly()``...
			equipItem:free()
		end
	end
	-- Update AC
	for i = creatureLevel + 1, summonerLevel do
		if i % 5 == 0 then
			EEex_LuaAction_Object:applyEffect({
				["effectID"] = 0, -- AC bonus
				["durationType"] = 1,
				["effectAmount"] = 1,
				["sourceID"] = EEex_LuaAction_Object.m_id,
				["sourceTarget"] = EEex_LuaAction_Object.m_id,
			})
		end
	end
end
