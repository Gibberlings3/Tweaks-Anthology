--[[
+--------------------------------------------------+
| cdtweaks, NWN-ish Cleave class feat for Fighters |
+--------------------------------------------------+
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
		sprite:setLocalInt("gtNWNCleave", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%FIGHTER_CLEAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["durationType"] = 9,
			["res"] = "%FIGHTER_CLEAVE%B", -- EFF file
			["m_sourceRes"] = "%FIGHTER_CLEAVE%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / flags
	local class = GT_Resource_SymbolToIDS["class"]
	-- any fighter class (single/multi/(complete)dual, as well as monks)
	local isFighterAll = GT_Sprite_CheckIDS(sprite, class["FIGHTER_ALL"], 5)
	--
	local applyAbility = isFighterAll
	--
	if sprite:getLocalInt("gtNWNCleave") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNCleave", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%FIGHTER_CLEAVE%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core function --

function %FIGHTER_CLEAVE%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform Cleave
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local conditionalString = 'InWeaponRange(EEex_Target("gtScriptingTarget"))'
		local responseString = 'ReallyForceSpellRES("%FIGHTER_CLEAVE%B",EEex_Target("gtScriptingTarget"))'
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		if EEex_IsBitSet(targetActiveStats.m_generalState, 11) then -- if STATE_DEAD (BIT11)
			local potentialTargets = {}
			if sourceSprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
				potentialTargets = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["GOODCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
			elseif sourceSprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
				potentialTargets = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["EVILCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
			end
			--
			for _, itrSprite in ipairs(potentialTargets) do
				local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
				--
				if GT_EvalConditional["parseConditionalString"](sourceSprite, itrSprite, conditionalString) and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 11) then -- if not dead
					if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or sourceActiveStats.m_bSeeInvisible > 0 then
						if itrSpriteActiveStats.m_bSanctuary == 0 then
							GT_ExecuteResponse["parseResponseString"](sourceSprite, itrSprite, responseString)
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
