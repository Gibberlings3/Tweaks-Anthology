-- Select a weapon (chosen at random from SLOT_WEAPON[1-4] / SLOT_FIST) --

function GT_LuaTrigger_SelectWeapon()
	local melee = {}
	local ranged = {}
	--
	local isWeaponRanged = EEex_Trigger_ParseConditionalString("IsWeaponRanged(Myself)")
	local withinMeleeRange = EEex_Trigger_ParseConditionalString("Range(NearestEnemyOf(Myself),4)")
	--
	local items = EEex_LuaTrigger_Object.m_equipment.m_items -- Array<CItem*,39>
	--
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			local ability = EEex_Resource_GetCItemAbility(item, 0) -- Item_ability_st
			--
			if ability.type == 1 then -- melee
				table.insert(melee, i)
			else -- ranged / launcher
				table.insert(ranged, i)
			end
		end
	end
	--
	if EEex_LuaTrigger_Object.m_typeAI.m_Class == 20 or (next(melee) == nil and next(ranged) == nil) then -- CLASS=MONK || no weapon
		table.insert(melee, 10) -- SLOT_FIST
	end
	-- Pick a random index from the arrays
	local randomIndex = -1
	local slotID = -1
	--
	if withinMeleeRange:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and isWeaponRanged:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and next(melee) then
		randomIndex = math.random(#melee)
		slotID = melee[randomIndex]
	elseif not withinMeleeRange:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and not isWeaponRanged:evalConditionalAsAIBase(EEex_LuaTrigger_Object) and next(ranged) then
		randomIndex = math.random(#ranged)
		slotID = ranged[randomIndex]
	end
	--
	isWeaponRanged:free()
	withinMeleeRange:free()
	--
	if randomIndex ~= -1 then
		EEex_LuaTrigger_Object:setLocalInt("gtAISelectWeaponAbility", slotID)
		return true
	else
		return false
	end
end

