--[[
+---------------------------------------------------------+
| cdtweaks, NWN-ish Sneak Attack kit feat for Blackguards |
+---------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual bonus
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksSneakattBlackguard", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "%BLACKGUARD_SNEAK_ATTACK%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["res"] = "%BLACKGUARD_SNEAK_ATTACK%B", -- EFF file
			["durationType"] = 9,
			["m_sourceRes"] = "%BLACKGUARD_SNEAK_ATTACK%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 249, -- Ranged hit effect
			["res"] = "%BLACKGUARD_SNEAK_ATTACK%B", -- EFF file
			["durationType"] = 9,
			["m_sourceRes"] = "%BLACKGUARD_SNEAK_ATTACK%",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's class / kit / flags
	local spriteFlags = sprite.m_baseStats.m_flags
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteKitStr = GT_Resource_IDSToSymbol["kit"][sprite.m_derivedStats.m_nKit]
	-- Grant the feat to Blackguards (must not be fallen)
	local applyAbility = spriteClassStr == "PALADIN" and spriteKitStr == "Blackguard" and EEex_IsBitUnset(spriteFlags, 9)
	--
	if sprite:getLocalInt("cdtweaksSneakattBlackguard") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksSneakattBlackguard", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%BLACKGUARD_SNEAK_ATTACK%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core function --

function %BLACKGUARD_SNEAK_ATTACK%(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform a sneak attack
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local targetActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
		-- limit to once per round
		local getTimer = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("cdtweaksSneakattBlckgrdTimer","LOCALS")')
		local setTimer = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksSneakattBlckgrdTimer","LOCALS",6)')
		--
		if getTimer:evalConditionalAsAIBase(sourceSprite) then
			-- if the target is incapacitated || the target is in combat with someone else || the blackguard is invisible
			if EEex_BAnd(targetActiveStats.m_generalState, 0x100029) ~= 0 or CGameSprite.m_targetId ~= sourceSprite.m_id or sourceSprite:getLocalInt("gtSpriteIsInvisible") == 1 then
				setTimer:executeResponseAsAIBaseInstantly(sourceSprite)
				--
				CGameSprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["res"] = "%BLACKGUARD_SNEAK_ATTACK%B", -- SPL file
					["dwFlags"] = 1, -- cast instantly / ignore level
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
		--
		getTimer:free()
		setTimer:free()
	elseif CGameEffect.m_effectAmount == 2 then -- actual sneak attack
		local sneakatt = GT_Resource_2DA["sneakatt"]
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		if selectedWeaponAbility.type == 1 and sourceSprite.m_leftAttack == 1 then -- if attacking with offhand ...
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand then
				local pHeader = offHand.pRes.pHeader -- Item_Header_st
				if not (pHeader.itemType == 0xC) then -- if not shield, then overwrite item ability...
					selectedWeaponAbility = EEex_Resource_GetItemAbility(pHeader, 0) -- Item_ability_st
				end
			end
		end
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
					["numDice"] = tonumber(sneakatt["STALKER"][string.format("%s", sourceActiveStats.m_nLevel1)]),
					["diceSize"] = 6,
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
