-- cdtweaks, revised backstab immunity (component #2620) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksBackstabImmunity", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDBSTIMM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 292, -- Immunity to backstab
			["dwFlags"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "CDBSTIMM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's general / race / class
	local spriteGeneralStr = GT_Resource_IDSToSymbol["general"][sprite.m_typeAI.m_General]
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local applyAbility = (spriteGeneralStr == "UNDEAD" or spriteGeneralStr == "WEAPON" or spriteGeneralStr == "PLANT")
		or (spriteRaceStr == "MIST" or spriteRaceStr == "SLIME" or spriteRaceStr == "BEHOLDER" or spriteRaceStr == "DEMONIC" or spriteRaceStr == "MEPHIT" or spriteRaceStr == "IMP" or spriteRaceStr == "ELEMENTAL" or spriteRaceStr == "SALAMANDER" or spriteRaceStr == "GENIE" or spriteRaceStr == "PLANATAR" or spriteRaceStr == "DARKPLANATAR" or spriteRaceStr == "SOLAR" or spriteRaceStr == "ANTISOLAR" or spriteRaceStr == "DRAGON" or spriteRaceStr == "SHAMBLING_MOUND")
		or (spriteClassStr == "GOLEM_IRON" or spriteClassStr == "GOLEM_STONE" or spriteClassStr == "GOLEM_CLAY" or spriteClassStr == "GOLEM_ICE")
	--
	if sprite:getLocalInt("cdtweaksBackstabImmunity") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksBackstabImmunity", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDBSTIMM",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
