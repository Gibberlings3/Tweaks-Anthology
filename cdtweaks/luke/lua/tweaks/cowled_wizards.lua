--[[
+----------------------------------------+
| cdtweaks, more sensible cowled wizards |
+----------------------------------------+
--]]

local cdtweaks_MoreSensibleCowledWizards = {
	["AR0020"] = true, -- City Gates
	["AR0300"] = true, -- The Docks
	["AR0400"] = true, -- Slums
	["AR0500"] = true, -- Bridge District
	["AR0700"] = true, -- Waukeen's Promenade
	["AR0900"] = true, -- Temple District
	["AR1000"] = true, -- Government District
}

-- set a GLOBAL var when a PC casts a wizard spell and is in Athkatla --

GTCOWENF = {

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
		--
		--local areaCheck = EEex_Trigger_ParseConditionalString('OR(7) \n AreaCheck("AR0020") AreaCheck("AR0300") AreaCheck("AR0400") AreaCheck("AR0500") AreaCheck("AR0700") AreaCheck("AR0900") AreaCheck("AR1000")')
		--
		local spellResRef = originatingSprite.m_curAction.m_string1.m_pchData:get()
		if spellResRef == "" then
			spellResRef = GT_Utility_DecodeSpell(originatingSprite.m_curAction.m_specificID)
		end
		--
		local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
		--
		if spellHeader.itemType == 1 and cdtweaks_MoreSensibleCowledWizards[originatingSprite.m_pArea.m_resref:get()] then -- if wizard spell and in Athkatla ...
			EEex_GameState_SetGlobalInt("gt_CowledWizardsTriggered", 1)
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
		sprite:setLocalInt("cdtweaksCowledWizards", 1)
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
				["res"] = "GTCOWENF",
				["m_sourceRes"] = "GTCOWENF",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's EA
	local applyCondition = sprite.m_typeAI.m_EnemyAlly == 2 -- PC
	--
	if sprite:getLocalInt("cdtweaksCowledWizards") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("cdtweaksCowledWizards", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTCOWENF",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
