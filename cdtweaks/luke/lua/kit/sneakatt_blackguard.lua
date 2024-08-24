-- cdtweaks, Sneak Attack feat for Blackguards --

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
			["durationType"] = 1,
			["res"] = "CDBLKGSA",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 248, -- Melee hit effect
			["res"] = "CDBLKGSA", -- EFF file
			["durationType"] = 9,
			["m_sourceRes"] = "CDBLKGSA",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 249, -- Ranged hit effect
			["res"] = "CDBLKGSA", -- EFF file
			["durationType"] = 9,
			["m_sourceRes"] = "CDBLKGSA",
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
				["durationType"] = 1,
				["res"] = "CDBLKGSA",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- cdtweaks, Sneak Attack feat for Blackguards --

function GTBLKGSA(CGameEffect, CGameSprite)
	if CGameEffect.m_effectAmount == 1 then -- check if can perform a sneak attack
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		--
		local targetGeneralState = CGameSprite.m_derivedStats.m_generalState + CGameSprite.m_bonusStats.m_generalState
		-- limit to once per round
		local getTimer = EEex_Trigger_ParseConditionalString('!GlobalTimerNotExpired("cdtweaksSneakattBlckgrdTimer","LOCALS")')
		local setTimer = EEex_Action_ParseResponseString('SetGlobalTimer("cdtweaksSneakattBlckgrdTimer","LOCALS",6)')
		--
		if getTimer:evalConditionalAsAIBase(sourceSprite) then
			-- if the target is incapacitated || the target is in combat with someone else || the blackguard is invisible
			if EEex_BAnd(targetGeneralState, 0x100029) ~= 0 or CGameSprite.m_targetId ~= sourceSprite.m_id or sourceSprite:getLocalInt("gtIsInvisible") == 1 then
				setTimer:executeResponseAsAIBaseInstantly(sourceSprite)
				--
				CGameSprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["res"] = "CDBLKGSA", -- SPL file
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
		local itemflag = GT_Resource_SymbolToIDS["itemflag"]
		--
		local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
		local sourceLevel = sourceSprite.m_derivedStats.m_nLevel1 + sourceSprite.m_bonusStats.m_nLevel1
		--
		local equipment = sourceSprite.m_equipment
		local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
		local selectedWeaponHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
		--
		local selectedWeaponAbility = EEex_Resource_GetItemAbility(selectedWeaponHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
		--
		if selectedWeaponAbility.type == 1 and EEex_BAnd(selectedWeaponHeader.itemFlags, itemflag["TWOHANDED"]) == 0 then -- if melee and single-handed
			local items = sourceSprite.m_equipment.m_items -- Array<CItem*,39>
			local offHand = items:get(9) -- CItem
			--
			if offHand and sourceSprite.m_leftAttack == 1 then
				local offHandHeader = offHand.pRes.pHeader -- Item_Header_st
				if not (offHandHeader.itemType == 0xC) then -- if not shield, then overwrite item ability...
					selectedWeaponAbility = EEex_Resource_GetItemAbility(offHandHeader, 0) -- Item_ability_st
				end
			end
		end
		--
		local randomValue = math.random(0, 1)
		local damageType = {0x10, 0, 0x100, 0x80, 0x800, 0x10 * randomValue, randomValue == 0 and 0x10 or 0x100, 0x100 * randomValue} -- piercing, crushing, slashing, missile, non-lethal, piercing/crushing, piercing/slashing, slashing/crushing
		--
		if damageType[selectedWeaponAbility.damageType] and tonumber(sneakatt["STALKER"][string.format("%s", sourceLevel)]) > 0 then
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 12, -- Damage
				["dwFlags"] = damageType[selectedWeaponAbility.damageType] * 0x10000, -- Normal
				["durationType"] = 1,
				["numDice"] = tonumber(sneakatt["STALKER"][string.format("%s", sourceLevel)]),
				["diceSize"] = 6,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
