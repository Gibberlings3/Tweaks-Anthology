-- Check if the attacker can perform an attack of opportunity. If so, return 4 (bonus to hit and damage) --

function GT_Sprite_GetAttackOfOpportunityBonus(attacker, target)
	local toReturn = 0
	--
	local attackerSelectedWeapon = GT_Sprite_GetSelectedWeapon(attacker)
	local targetSelectedWeapon = GT_Sprite_GetSelectedWeapon(target)
	--
	local attackerClassIDS = attacker.m_typeAI.m_Class
	local targetClassIDS = target.m_typeAI.m_Class
	--
	local attackerAbilityNotRanged = attackerSelectedWeapon["ability"].type == 1
	local attackerNotUsingFists = attackerSelectedWeapon["slot"] ~= 10 or attackerClassIDS == 20
	--
	local targetAbilityNotRanged = targetSelectedWeapon["ability"].type == 1
	local targetNotUsingFists = targetSelectedWeapon["slot"] ~= 10 or targetClassIDS == 20
	-- (attacker not using non-monk fists and attacker not using ranged ability) and (target using non-monk fists or target using ranged weapon)
	if attackerAbilityNotRanged and attackerNotUsingFists then
		if not (targetAbilityNotRanged and targetNotUsingFists) then
			toReturn = 4
		end
	end
	--
	return toReturn
end

