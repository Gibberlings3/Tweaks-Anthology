--[[
+----------------------------------------------------------------------------------------------------------------------+
| Snakes fear fire and will retreat from open flames, suffering a -1 morale modifier when flames are used against them |
+----------------------------------------------------------------------------------------------------------------------+
--]]

function %INNATE_SNAKE_RETREAT_FROM_OPEN_FLAMES%(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	--local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
	--
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) then -- Damage (FIRE)
		if spriteActiveStats.m_nResistFire < 100 then -- only apply if the target is not immune to fire
			-- op403 "sees" effects after they have passed their probability roll, but before any saving throws have been made against said effect / other immunity mechanisms have taken place
			-- opcodes applied here *should* use the same roll for saves and mr checks...
			-- moreover, the morale modifier penalty *should* not be bounced back...
			if not GT_Sprite_HasBounceEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {12, 23, 146, 24}, CGameEffect.m_flags, false) then
				if not GT_Sprite_HasImmunityEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {12, 23, 146, 24}, CGameEffect.m_flags, CGameEffect.m_savingThrow, 0x0, false) then
					if not GT_Sprite_HasTrapEffect(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_secondaryType, CGameEffect.m_flags, false) then
						CGameSprite:applyEffect({
							["effectID"] = 146, -- cast spell
							["dwFlags"] = 1, -- instant/ignore level
							--
							["savingThrow"] = EEex_IsBitSet(CGameEffect.m_special, 0x8) and 0 or CGameEffect.m_savingThrow, -- ignore save check if the save for half flag is set
							["saveMod"] = CGameEffect.m_saveMod,
							["m_flags"] = CGameEffect.m_flags,
							--
							["durationType"] = CGameEffect.m_durationType,
							["duration"] = CGameEffect.m_duration,
							--
							["spellLevel"] = CGameEffect.m_spellLevel,
							["m_projectileType"] = CGameEffect.m_projectileType,
							["m_school"] = CGameEffect.m_school,
							["m_secondaryType"] = CGameEffect.m_secondaryType,
							["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
							--
							["m_sourceType"] = CGameEffect.m_sourceType,
							["m_sourceFlags"] = CGameEffect.m_sourceFlags,
							["m_casterLevel"] = CGameEffect.m_casterLevel,
							["m_slotNum"] = CGameEffect.m_slotNum,
							--
							["res"] = "%INNATE_SNAKE_RETREAT_FROM_OPEN_FLAMES%",
							--
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
					end
				end
			end
		end
	end
end

