--[[
+----------------------------------------------------------------------+
| cdtweaks, NWN-ish Uncanny Dodge class feat for Barbarians and Rogues |
+----------------------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtBarbThfUncannyDodge", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%BARBARIAN_THIEF_UNCANNY_DODGE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%BARBARIAN_THIEF_UNCANNY_DODGE%", -- Lua func
			["m_sourceRes"] = "%BARBARIAN_THIEF_UNCANNY_DODGE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags / levels
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	-- KIT=BARBARIAN || CLASS=THIEF
	local isThief = spriteClassStr == "THIEF" or spriteClassStr == "FIGHTER_MAGE_THIEF"
		or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x6) or spriteLevel1 > spriteLevel2))
	--
	local isBarbarian = spriteKitStr == "BARBARIAN"
		and (spriteClassStr == "FIGHTER"
			or (spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
			or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
			or (spriteClassStr == "FIGHTER_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1))
			or (spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x3) or spriteLevel2 > spriteLevel1)))
	--
	local applyAbility = isThief or isBarbarian
	--
	if sprite:getLocalInt("gtBarbThfUncannyDodge") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtBarbThfUncannyDodge", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%BARBARIAN_THIEF_UNCANNY_DODGE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op403 listener --

function %BARBARIAN_THIEF_UNCANNY_DODGE%(op403CGameEffect, CGameEffect, CGameSprite)
	local id = CGameEffect.m_sourceId
	local object = EEex_GameObject_Get(id)
	--
	local objectSources = {
		[CGameObjectType.TRIGGER] = true,
		[CGameObjectType.DOOR] = true,
		[CGameObjectType.CONTAINER] = true,
	}
	--
	if object and objectSources[object.m_objectType] then
		CGameEffect.m_saveMod = CGameEffect.m_saveMod + 2
	end
end
