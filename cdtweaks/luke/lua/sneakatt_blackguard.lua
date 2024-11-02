-- cdtweaks, Sneak Attack feat for Blackguards --

function GTBLKG01(CGameEffect, CGameSprite)
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
				["res"] = "GTBLKGSA", -- SPL file
				["dwFlags"] = 1, -- cast instantly / ignore level
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
	--
	getTimer:free()
	setTimer:free()
end

-- cdtweaks, Sneak Attack feat for Blackguards --

function GTBLKG02(CGameEffect, CGameSprite)
	local sneakatt = GT_Resource_2DA["sneakatt"]
	--
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	local sourceLevel = sourceSprite.m_derivedStats.m_nLevel1 + sourceSprite.m_bonusStats.m_nLevel1
	--
	local equipment = sourceSprite.m_equipment
	local selectedWeapon = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedWeapon.pRes.pHeader -- Item_Header_st
	--
	local itemAbility = EEex_Resource_GetItemAbility(itemHeader, equipment.m_selectedWeaponAbility) -- Item_ability_st
	--
	local randomValue = math.random(0, 1)
	local damageType = {16, 0, 256, 128, 2048, 16 * randomValue, randomValue == 0 and 16 or 256, 256 * randomValue} -- piercing, crushing, slashing, missile, non-lethal, piercing/crushing, piercing/slashing, slashing/crushing
	--
	if damageType[itemAbility.damageType] and tonumber(sneakatt["STALKER"][string.format("%s", sourceLevel)]) > 0 then
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 12, -- Damage
			["dwFlags"] = damageType[itemAbility.damageType] * 0x10000, -- Normal
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
