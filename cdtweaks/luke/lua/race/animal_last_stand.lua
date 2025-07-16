--[[
+------------------------------------------------------+
| cdtweaks, Last Stand innate feat for Bears and Boars |
+------------------------------------------------------+
--]]

function %INNATE_ANIMAL_LAST_STAND%(op403CGameEffect, CGameEffect, CGameSprite)
	if CGameEffect.m_effectId == 0xD then -- kill target (op13)
		if not GT_Sprite_HasBounceEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {13}, CGameEffect.m_flags, false) then
			if not GT_Sprite_HasImmunityEffects(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_projectileType, CGameEffect.m_school, CGameEffect.m_secondaryType, CGameEffect.m_sourceRes:get(), {13}, CGameEffect.m_flags, CGameEffect.m_savingThrow, 0x0, false) then
				if not GT_Sprite_HasTrapEffect(CGameSprite, CGameEffect.m_spellLevel, CGameEffect.m_secondaryType, CGameEffect.m_flags, false) then
					CGameSprite:applyEffect({
						["effectID"] = CGameEffect.m_effectId, -- Kill target
						["dwFlags"] = CGameEffect.m_dWFlags,
						["effectAmount"] = CGameEffect.m_effectAmount,
						--
						["savingThrow"] = CGameEffect.m_savingThrow,
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
						["m_maxLevel"] = CGameEffect.m_maxLevel,
						["m_minLevel"] = CGameEffect.m_minLevel,
						--
						["noSave"] = true, -- ignore immunity provided by op208
						--
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
					--
					return true
				end
			end
		end
	end
end

-- The boar/bear will fight for (1d4/1d4+1) rounds after reaching 0 hit points. The creature will go berserk attacking friends and foes alike --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- Check creature's general / class / race / animate
	local spriteGeneralStr = GT_Resource_IDSToSymbol["general"][sprite.m_typeAI.m_General]
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	local spriteAnimateStr = GT_Resource_IDSToSymbol["animate"][sprite.m_animation.m_animation.m_animationID]
	--
	local modifier = -1
	--
	if spriteGeneralStr == "ANIMAL" then
		if spriteRaceStr == "BEAR" then
			if spriteClassStr == "BEAR_BROWN" or spriteClassStr == "BEAR_CAVE" then
				modifier = 0
			elseif spriteClassStr == "BEAR_POLAR" then
				modifier = 1
			end
		elseif spriteAnimateStr == "BOAR_ARCTIC" or spriteAnimateStr == "BOAR_WILD" then
			modifier = 1
		end
	end
	--
	local roll = modifier + Infinity_RandomNumber(1, 4) -- 1d4 / 1d4+1
	--
	if sprite:getLocalInt("gtAnimalLastStand") == 1 then
		if sprite.m_nLastDamageTaken >= sprite.m_baseStats.m_hitPoints and sprite:getLocalInt("gtAnimalRunningWild") == 0 then
			sprite:setLocalInt("gtAnimalRunningWild", 1)
			--
			local lastHitter = EEex_GameObject_Get(sprite.m_lHitter.m_Instance)
			--
			local effectCodes = {
				{["op"] = 3, ["p2"] = 1, ["dur"] = 6 * roll}, -- berserk (mode: constant)
				{["op"] = 176, ["p2"] = 5, ["p1"] = 200, ["dur"] = 6 * roll}, -- movement rate bonus (200%)
				{["op"] = 215, ["res"] = "ICSTRENI", ["p2"] = 1, ["dur"] = 2}, -- play visual effect (over target: attached)
				{["op"] = 142, ["p2"] = 4, ["dur"] = 6 * roll}, -- icon: berserk
				{["op"] = 187, ["p1"] = 0, ["effvar"] = "gtAnimalRunningWild", ["dur"] = 6 * roll, ["tmg"] = 4}, -- set local var (reset to 0 in case the animal gets resurrected)
				{["op"] = 55, ["p2"] = 2, ["dur"] = 6 * roll, ["tmg"] = 4}, -- slay creature
			}
			--
			for _, attributes in ipairs(effectCodes) do
				sprite:applyEffect({
					["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
					["effectAmount"] = attributes["p1"] or 0,
					["dwFlags"] = attributes["p2"] or 0,
					["res"] = attributes["res"] or "",
					["duration"] = attributes["dur"] or 0,
					["durationType"] = attributes["tmg"] or 0,
					["m_scriptName"] = attributes["effvar"] or "",
					["m_sourceRes"] = "%INNATE_ANIMAL_LAST_STAND%B",
					["m_sourceType"] = 1,
					["noSave"] = true,
					["sourceID"] = lastHitter.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
		end
	end
end)

-- Apply passive trait --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtAnimalLastStand", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%INNATE_ANIMAL_LAST_STAND%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 208, -- Min HP
			["effectAmount"] = 1,
			["durationType"] = 9,
			["m_sourceRes"] = "%INNATE_ANIMAL_LAST_STAND%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "%INNATE_ANIMAL_LAST_STAND%", -- Lua func
			["m_sourceRes"] = "%INNATE_ANIMAL_LAST_STAND%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})

	end
	-- Check creature's general / class / race / animate
	local spriteGeneralStr = GT_Resource_IDSToSymbol["general"][sprite.m_typeAI.m_General]
	local spriteRaceStr = GT_Resource_IDSToSymbol["race"][sprite.m_typeAI.m_Race]
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	local spriteAnimateStr = GT_Resource_IDSToSymbol["animate"][sprite.m_animation.m_animation.m_animationID]
	--
	local applyAbility = false
	--
	if spriteGeneralStr == "ANIMAL" then
		if spriteRaceStr == "BEAR" then
			if spriteClassStr == "BEAR_BROWN" or spriteClassStr == "BEAR_CAVE" or spriteClassStr == "BEAR_POLAR" then
				applyAbility = true
			end
		elseif spriteAnimateStr == "BOAR_ARCTIC" or spriteAnimateStr == "BOAR_WILD" then
			applyAbility = true
		end
	end
	--
	if sprite:getLocalInt("gtAnimalLastStand") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtAnimalLastStand", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%INNATE_ANIMAL_LAST_STAND%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
