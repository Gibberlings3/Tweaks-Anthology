--[[
+-------------------------------------------------------+
| cdtweaks, revised backstab immunity (component #2620) |
+-------------------------------------------------------+
--]]

local cdtweaks_RevisedBackstabImmunity_General = {
	["UNDEAD"] = true,
	["WEAPON"] = true,
	["PLANT"] = true,
}

local cdtweaks_RevisedBackstabImmunity_Race = {
	["MIST"] = true,
	["SLIME"] = true,
	["BEHOLDER"] = true,
	["DEMONIC"] = true,
	["MEPHIT"] = true,
	["IMP"] = true,
	["ELEMENTAL"] = true,
	["SALAMANDER"] = true,
	["GENIE"] = true,
	["PLANATAR"] = true,
	["DARKPLANATAR"] = true,
	["SOLAR"] = true,
	["ANTISOLAR"] = true,
	["DRAGON"] = true,
	["SHAMBLING_MOUND"] = true,
}

local cdtweaks_RevisedBackstabImmunity_Class = {
	["GOLEM_IRON"] = true,
	["GOLEM_STONE"] = true,
	["GOLEM_CLAY"] = true,
	["GOLEM_ICE"] = true,
}

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtBackstabImmunity", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTRULE03",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 292, -- Immunity to backstab
			["dwFlags"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "GTRULE03",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's general / race / class
	local spriteGeneralStr = GT_Resource_IDSToSymbol["general"][sprite.m_typeAI.m_General]
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local applyAbility = cdtweaks_RevisedBackstabImmunity_General[spriteGeneralStr] or cdtweaks_RevisedBackstabImmunity_Race[spriteRaceStr] or cdtweaks_RevisedBackstabImmunity_Class[spriteClassStr]
	--
	if sprite:getLocalInt("gtBackstabImmunity") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("gtBackstabImmunity", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTRULE03",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
