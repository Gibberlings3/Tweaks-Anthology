-- cdtweaks: NWN-ish Metamagic feat for spellcasters --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that grants the actual feat
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("cdtweaksMetamagic", 1)
		--
		local res = {"CDMTMQCK", "CDMTMEMP", "CDMTMMAX", "CDMTMEXT"}
		for _, v in ipairs(res) do
			sprite:applyEffect({
				["effectID"] = 172, -- Remove spell
				["durationType"] = 1,
				["res"] = v,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 171, -- Give spell
				["durationType"] = 1,
				["res"] = v,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["durationType"] = 1,
			["res"] = "CDMMAGIC",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 408, -- Projectile mutator
			["durationType"] = 9,
			["res"] = "GTMMAGIC", -- lua function
			["m_sourceRes"] = "CDMMAGIC",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- Check if spellcaster class -- single/multi/(complete)dual
	local gainAbility = spriteClassStr == "MAGE" or spriteClassStr == "CLERIC" or spriteClassStr == "DRUID" or spriteClassStr == "FIGHTER_MAGE_THIEF" or spriteClassStr == "FIGHTER_MAGE_CLERIC" or spriteClassStr == "CLERIC_MAGE"
		or (spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x7) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
	--
	if sprite:getLocalInt("cdtweaksMetamagic") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksMetamagic", 0)
			--
			local res = {"CDMTMQCK", "CDMTMEMP", "CDMTMMAX", "CDMTMEXT"}
			for _, v in ipairs(res) do
				sprite:applyEffect({
					["effectID"] = 172, -- Remove spell
					["durationType"] = 1,
					["res"] = v,
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDMMAGIC",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
