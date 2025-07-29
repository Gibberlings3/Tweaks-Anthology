--[[
+----------------------------------------------------+
| cdtweaks, NWN-ish Circle Kick class feat for Monks |
+----------------------------------------------------+
--]]

-- Apply Ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNCircleKick", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%MONK_CIRCLE_KICK%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["dwFlags"] = 4, -- fist-only
			["durationType"] = 9,
			["res"] = "%MONK_CIRCLE_KICK%B", -- EFF file
			["m_sourceRes"] = "%MONK_CIRCLE_KICK%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	--
	local applyAbility = spriteClassStr == "MONK"
	--
	if sprite:getLocalInt("gtNWNCircleKick") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNCircleKick", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%MONK_CIRCLE_KICK%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core function --

function %MONK_CIRCLE_KICK%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform a circle kick
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		-- limit to once per round
		local conditionalString = '!GlobalTimerNotExpired("gtNWNCircleKickTimer","LOCALS") \n InWeaponRange(EEex_Target("gtCircleKickTarget"))'
		local responseString = 'SetGlobalTimer("gtNWNCircleKickTimer","LOCALS",6) \n ReallyForceSpellRES("%MONK_CIRCLE_KICK%B",EEex_Target("gtCircleKickTarget"))'
		--
		local potentialTargets = {}
		if sourceSprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			potentialTargets = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["GOODCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		elseif sourceSprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			potentialTargets = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["EVILCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		end
		--
		for _, itrSprite in ipairs(potentialTargets) do
			if itrSprite.m_id ~= CGameSprite.m_id then -- skip current target
				--EEex_LuaObject = itrSprite -- must be global (we are not confortable with global / singleton vars...)
				--sourceSprite:setStoredScriptingTarget("gt_NWN_CircleKick_Target", itrSprite)
				--
				local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
				--
				if GT_EvalConditional["parseConditionalString"](sourceSprite, itrSprite, conditionalString, "gtCircleKickTarget") and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 11) then -- if not dead
					if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or sourceActiveStats.m_bSeeInvisible > 0 then -- if not invisible or can see through invisibility
						if itrSpriteActiveStats.m_bSanctuary == 0 then
							GT_ExecuteResponse["parseResponseString"](sourceSprite, itrSprite, responseString, "gtCircleKickTarget")
							break
						end
					end
				end
			end
		end
	elseif CGameEffect.m_effectAmount == 2 then -- actual feat
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(sourceSprite)
		--
		local conditionalString = "EEex_IsImmuneToOpcode(Myself,12)"
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local damageTypeIDS, ACModifier = GT_Sprite_ItmDamageTypeToIDS(selectedWeapon["ability"].damageType, targetActiveStats)
		--
		if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, conditionalString) then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0xC, -- Damage
				["dwFlags"] = damageTypeIDS * 0x10000, -- mode: normal
				["numDice"] = selectedWeapon["ability"].damageDiceCount,
				["diceSize"] = selectedWeapon["ability"].damageDice,
				["effectAmount"] = selectedWeapon["ability"].damageDiceBonus,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		else
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 324, -- Immunity to resource and message
				["res"] = CGameEffect.m_sourceRes:get(),
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
