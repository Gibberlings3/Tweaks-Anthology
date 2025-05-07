--[[
+-----------------------+
| True Strike (cantrip) |
+-----------------------+
--]]

-- nuke spell after first attack roll --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local spriteAux = EEex_GetUDAux(sprite)
	--
	local found = false
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 142 and effect.m_dWFlags == %feedback_icon% then
			found = true
			return true -- break
		end
	end)
	--
	if found then
		if sprite.m_startedSwing == 1 then
			if not spriteAux["gtWizardTrueStrike"] then
				spriteAux["gtWizardTrueStrike"] = true
			end
		else
			if spriteAux["gtWizardTrueStrike"] then
				spriteAux["gtWizardTrueStrike"] = false
				--
				sprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["res"] = "%WIZARD_TRUE_STRIKE%",
					["noSave"] = true,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

