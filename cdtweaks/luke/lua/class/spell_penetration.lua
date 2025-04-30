--[[
+---------------------------------------------------------+
| cdtweaks, Spell Penetration class feat for Spellcasters |
+---------------------------------------------------------+
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
		sprite:setLocalInt("gtNWNSpellPenetration", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%SPELLCASTER_SPELL_PENETRATION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 408, -- EEex: Projectile Mutator
			["durationType"] = 9,
			["res"] = "%SPELLCASTER_SPELL_PENETRATION%P", -- Lua func
			["m_sourceRes"] = "%SPELLCASTER_SPELL_PENETRATION%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / levels
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local spriteFlags = sprite.m_baseStats.m_flags
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
	local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
	-- Spellcaster classes (all but rangers, paladins, bards)
	local isTripleClass = spriteClassStr == "FIGHTER_MAGE_THIEF" or spriteClassStr == "FIGHTER_MAGE_CLERIC"
	--
	local isClericMage = spriteClassStr == "CLERIC_MAGE"
	--
	local isShaman = spriteClassStr == "SHAMAN"
	--
	local isDruid = spriteClassStr == "DRUID" or (spriteClassStr == "FIGHTER_DRUID" and (EEex_IsBitUnset(spriteFlags, 0x7) or spriteLevel1 > spriteLevel2))
	--
	local isCleric = spriteClassStr == "CLERIC"
		or (spriteClassStr == "FIGHTER_CLERIC" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "CLERIC_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
		or (spriteClassStr == "CLERIC_RANGER" and (EEex_IsBitUnset(spriteFlags, 0x5) or spriteLevel2 > spriteLevel1))
	--
	local isMage = spriteClassStr == "MAGE"
		or (spriteClassStr == "FIGHTER_MAGE" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel1 > spriteLevel2))
		or (spriteClassStr == "MAGE_THIEF" and (EEex_IsBitUnset(spriteFlags, 0x4) or spriteLevel2 > spriteLevel1))
	--
	local isSorcerer = spriteClassStr == "SORCERER"
	--
	local applyAbility = isTripleClass or isClericMage or isShaman or isDruid or isCleric or isMage or isSorcerer
	--
	if sprite:getLocalInt("gtNWNSpellPenetration") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- Do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNSpellPenetration", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%SPELLCASTER_SPELL_PENETRATION%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- op402 listener (alter target's mr roll) --

function %SPELLCASTER_SPELL_PENETRATION%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--
	if EEex_Sprite_GetStat(CGameSprite, 18) < 100 then -- skip if mr >= 100
		if CGameSprite.m_id ~= sourceSprite.m_id then -- skip if caster
			-- Compute modifier based on caster level (cap at 30...?)
			local modifier = EEex_Sprite_GetCasterLevelForSpell(sourceSprite, CGameEffect.m_res2:get(), true)
			if modifier > 30 then
				modifier = 30
			end
			-- alter roll
			CGameSprite.m_magicResistRoll = CGameSprite.m_magicResistRoll + modifier
		end
	end
end

-- op408 listener --

%SPELLCASTER_SPELL_PENETRATION%P = {

	["typeMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Spell] = true,
			[EEex_Projectile_DecodeSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
	end,

	["projectileMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Spell] = true,
			[EEex_Projectile_DecodeSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		-- get spell resref
		local spellResRef = originatingSprite.m_curAction.m_string1.m_pchData:get()
		if spellResRef == "" then
			spellResRef = GT_Utility_DecodeSpell(originatingSprite.m_curAction.m_specificID)
		end
		--
		local projectile = context["projectile"] -- CProjectile
		--
		projectile:AddEffect(GT_Utility_DecodeEffect(
			{
				["effectID"] = 402, -- EEex: Invoke Lua
				["res"] = "%SPELLCASTER_SPELL_PENETRATION%", -- lua func
				["m_res2"] = spellResRef,
				["sourceX"] = originatingSprite.m_pos.x,
				["sourceY"] = originatingSprite.m_pos.y,
				["sourceID"] = originatingSprite.m_id,
			}
		))
	end,

	["effectMutator"] = function(context)
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameSprite_Spell] = true,
			[EEex_Projectile_AddEffectSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_AddEffectSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_AddEffectSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.addEffectSource] then
			return
		end
	end,
}
