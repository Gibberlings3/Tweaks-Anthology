--[[
+----------------------------------------------------------------------+
| Fix "MakeGlobal()" messing up with GENERAL upon saving and reloading |
+----------------------------------------------------------------------+
--]]

function GT_NWN_AnmlComp_FixGeneral()
	if EEex_LuaAction_Object.m_scriptName:get() == "gtAnmlCompSpider" then
		EEex_LuaAction_Object:applyEffect({
			["effectID"] = 72, -- change AI type
			["durationType"] = 1,
			["dwFlags"] = 1, -- GENERAL
			["effectAmount"] = 255, -- MONSTER
			["noSave"] = true,
			["sourceID"] = EEex_LuaAction_Object.m_id,
			["sourceTarget"] = EEex_LuaAction_Object.m_id,
		})
	else
		EEex_LuaAction_Object:applyEffect({
			["effectID"] = 72, -- change AI type
			["durationType"] = 1,
			["dwFlags"] = 1, -- GENERAL
			["effectAmount"] = 2, -- ANIMAL
			["noSave"] = true,
			["sourceID"] = EEex_LuaAction_Object.m_id,
			["sourceTarget"] = EEex_LuaAction_Object.m_id,
		})
	end
end

