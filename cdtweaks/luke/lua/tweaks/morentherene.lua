--[[
+--------------------------------------+
| cdtweaks, more sensible Morentherene |
+--------------------------------------+
--]]

-- [SoD] make sure op146*p2=1 and &c. do not set global var "BD_GREEN_DRAGON_AWAKE" --

GTMORENT = {

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
		local areaSources = {
			["BD7210"] = true, -- Wyrm Cave
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		if EEex_GameState_GetGlobalInt("BD_GREEN_DRAGON_AWAKE") == 0 and areaSources[originatingSprite.m_pArea.m_resref:get()] then -- if wizard/priest/innate spell and in Wyrm Cave ...
			EEex_GameState_SetGlobalInt("BD_GREEN_DRAGON_AWAKE", 1)
		end
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

--

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual condition
	local apply = function()
		-- Mark the creature as 'condition applied'
		sprite:setLocalInt("gtMoreSensibleMorentherene", 1)
		--
		local effectCodes = {
			{["op"] = 321}, -- Remove effects by resource
			{["op"] = 408}, -- Projectile mutator
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 9,
				["res"] = "GTMORENT",
				["m_sourceRes"] = "GTMORENT",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's EA
	local applyCondition = sprite.m_typeAI.m_EnemyAlly < 30 -- GOODCUTOFF
	--
	if sprite:getLocalInt("gtMoreSensibleMorentherene") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("gtMoreSensibleMorentherene", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTMORENT",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

