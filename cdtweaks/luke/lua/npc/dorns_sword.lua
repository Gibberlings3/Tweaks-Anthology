--[[
+------------------------------------+
| cdtweaks, Rancor +1 (Dorn's sword) |
+------------------------------------+
--]]

function GTSW2HD1(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then
		-- check if Dorn made the kill
		local parentResRef = CGameEffect.m_sourceRes:get() -- We need to use :get() to export a CResRef field as a Lua string!
		local spriteScriptName = CGameSprite.m_scriptName:get()
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
	elseif CGameEffect.m_effectAmount == 2 then
		-- if Dorn is not wielding Rancor +1, then remove bonus ...
		local equipment = CGameSprite.m_equipment -- CGameSpriteEquipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponResRef = selectedWeapon.pRes.resref:get() -- We need to use :get() to export a CResRef field as a Lua string!
		-- if Dorn is not wielding Rancor +1, then remove bonus ...
		if string.upper(selectedWeaponResRef) ~= "SW2HD1" then
			if EEex_Sprite_GetLocalInt(CGameSprite, "ohdornsw") ~= 0 then
				EEex_Sprite_SetLocalInt(CGameSprite, "ohdornsw", 0)
				--
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- Cast instantly (caster level)
					["res"] = "OHDSW0",
					["sourceID"] = CGameEffect.m_sourceId, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
					["sourceTarget"] = CGameEffect.m_sourceTarget, -- Certain opcodes (see f.i. op326) use this field internally... it's probably a good idea to always specify it...
				})
			end
		end
	end
end

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if EEex_Sprite_GetLocalInt(sprite, "ohdornsw") ~= 0 then
		if action.m_actionID == 21 then
			EEex_Sprite_SetLocalInt(sprite, "ohdornsw", 0)
			--
			EEex_GameObject_ApplyEffect(sprite,
			{
				["effectID"] = 146, -- Cast spell
				["dwFlags"] = 1, -- Cast instantly (caster level)
				["res"] = "OHDSW0",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)