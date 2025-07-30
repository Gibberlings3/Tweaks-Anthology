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
		sprite:setLocalInt("gtNWNUncannyDodge", 1)
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
	local class = GT_Resource_SymbolToIDS["class"]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = EEex_Resource_KitIDSToSymbol(sprite.m_derivedStats.m_nKit)
	-- KIT=BARBARIAN || CLASS=THIEF
	local isThiefAll = GT_Sprite_CheckIDS(sprite, class["THIEF_ALL"], 5)
	local isFighterAll = GT_Sprite_CheckIDS(sprite, class["FIGHTER_ALL"], 5)
	local isBarbarian = spriteKitStr == "BARBARIAN"
	--
	local applyAbility = isThiefAll or (isBarbarian and isFighterAll)
	--
	if sprite:getLocalInt("gtNWNUncannyDodge") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNUncannyDodge", 0)
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
