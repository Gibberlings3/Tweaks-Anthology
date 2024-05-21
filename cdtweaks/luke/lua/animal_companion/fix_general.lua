-- cdtweaks, Animal Companion: fix "MakeGlobal()" messing up with GENERAL upon saving and reloading --

function GT_AnimalCompanion_FixGeneral()
	if EEex_LuaAction_Object.m_scriptName:get() == "gtAnmlCompSpider" then
		EEex_LuaAction_Object.m_typeAI.m_General = 255 -- MONSTER
	else
		EEex_LuaAction_Object.m_typeAI.m_General = 2 -- ANIMAL
	end
end
