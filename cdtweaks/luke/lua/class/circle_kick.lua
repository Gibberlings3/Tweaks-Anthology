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
		sprite:setLocalInt("cdtweaksCircleKick", 1)
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
	if sprite:getLocalInt("cdtweaksCircleKick") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksCircleKick", 0)
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
		local getTimer = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("cdtweaksCircleKickTimer","LOCALS") \n InWeaponRange(EEex_Target("GT_MonkCircleKickTarget"))')
		local setTimer = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksCircleKickTimer","LOCALS",6) \n ReallyForceSpellRES("%MONK_CIRCLE_KICK%B",EEex_Target("GT_MonkCircleKickTarget"))')
		--
		local spriteArray = {}
		if sourceSprite.m_typeAI.m_EnemyAlly > 200 then -- EVILCUTOFF
			spriteArray = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["GOODCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		elseif sourceSprite.m_typeAI.m_EnemyAlly < 30 then -- GOODCUTOFF
			spriteArray = EEex_Sprite_GetAllOfTypeInRange(sourceSprite, GT_AI_ObjectType["EVILCUTOFF"], sourceSprite:virtual_GetVisualRange(), nil, nil, nil)
		end
		--
		for _, itrSprite in ipairs(spriteArray) do
			if itrSprite.m_id ~= CGameSprite.m_id then -- skip current target
				--EEex_LuaObject = itrSprite -- must be global (we are not confortable with global / singleton vars...)
				sourceSprite:setStoredScriptingTarget("GT_MonkCircleKickTarget", itrSprite)
				--
				local itrSpriteActiveStats = EEex_Sprite_GetActiveStats(itrSprite)
				--
				if getTimer:evalConditionalAsAIBase(sourceSprite) and EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 11) then -- if not dead
					if EEex_IsBitUnset(itrSpriteActiveStats.m_generalState, 0x4) or sourceActiveStats.m_bSeeInvisible > 0 then -- if not invisible or can see through invisibility
						if itrSpriteActiveStats.m_bSanctuary == 0 then
							setTimer:executeResponseAsAIBaseInstantly(sourceSprite)
							break
						end
					end
				end
			end
		end
		--
		getTimer:free()
		setTimer:free()
	elseif CGameEffect.m_effectAmount == 2 then -- actual feat
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local equipment = sourceSprite.m_equipment -- CGameSpriteEquipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon) -- CItem
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		local immunityToDamage = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,12)")
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		--
		local itmAbilityDamageTypeToIDS = {
			0x10, -- piercing
			0x0, -- crushing
			0x100, -- slashing
			0x80, -- missile
			0x800, -- non-lethal
			targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistCrushing and 0x0 or 0x10, -- piercing/crushing (better)
			targetActiveStats.m_nResistPiercing > targetActiveStats.m_nResistSlashing and 0x100 or 0x10, -- piercing/slashing (better)
			targetActiveStats.m_nResistCrushing > targetActiveStats.m_nResistSlashing and 0x0 or 0x100, -- slashing/crushing (worse)
		}
		--
		if itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] then -- sanity check
			if not immunityToDamage:evalConditionalAsAIBase(CGameSprite) then
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 0xC, -- Damage
					["dwFlags"] = itmAbilityDamageTypeToIDS[selectedWeaponAbility.damageType] * 0x10000, -- mode: normal
					["numDice"] = selectedWeaponAbility.damageDiceCount,
					["diceSize"] = selectedWeaponAbility.damageDice,
					["effectAmount"] = selectedWeaponAbility.damageDiceBonus,
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
		--
		immunityToDamage:free()
	end
end
