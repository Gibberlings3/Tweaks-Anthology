-- cdtweaks, Rancor +1 (Dorn's sword): remove thac0 bonus when unequipped --

function GTDRNSW1(CGameEffect, CGameSprite)
	local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
	local itemResRef = selectedItem.pRes.resref:get() -- We need to use :get() to export a CResRef field as a Lua string!
	-- if Dorn is not wielding Rancor +1, then remove bonus ...
	if itemResRef ~= "SW2HD1" then
		if EEex_Sprite_GetLocalInt(CGameSprite, "ohdornsw") ~= 0 then
			EEex_Sprite_SetLocalInt(CGameSprite, "ohdornsw", 0)
			--
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 146, -- Cast spell
				["durationType"] = 1,
				["dwFlags"] = 1, -- Cast instantly (caster level)
				["res"] = "OHDSW0",
				["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			})
		end
	end
end

-- cdtweaks, Rancor +1 (Dorn's sword): Check if the wielder is Dorn --

function GTDRNSW2(CGameEffect, CGameSprite)
	local parentResRef = CGameEffect.m_sourceRes:get() -- We need to use :get() to export a CResRef field as a Lua string!
	local spriteScriptName = EEex_CastUD(CGameSprite.m_scriptName, "CResRef"):get() -- certain engine types are nonsensical. We usually create fixups for the bindings whenever we run into them. We'll need to cast the value to properly read them
	--
	if string.upper(spriteScriptName) ~= "DORN" then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 206, -- Protection from spell
			["effectAmount"] = -1, -- no feedback
			["res"] = parentResRef,
			["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
			["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
		})
	end
end