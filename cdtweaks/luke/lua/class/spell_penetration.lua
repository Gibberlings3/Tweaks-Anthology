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
	local class = GT_Resource_SymbolToIDS["class"]
	-- Spellcaster classes (all but rangers, paladins, bards)
	local isMageAll = GT_Sprite_CheckIDS(sprite, class["MAGE_ALL"], 5)
	local isDruidAll = GT_Sprite_CheckIDS(sprite, class["DRUID_ALL"], 5)
	local isClericAll = GT_Sprite_CheckIDS(sprite, class["CLERIC_ALL"], 5)
	local isShaman = GT_Sprite_CheckIDS(sprite, class["SHAMAN"], 5)
	--
	local applyAbility = isMageAll or isDruidAll or isClericAll or isShaman
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
