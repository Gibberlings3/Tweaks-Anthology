-- Returns true if the attacking sprite is flanking the targeted sprite --

function GT_Sprite_IsFlanking(attackerDirection, targetDirection)
	-- Normalize directions to ensure they are between 0 and 15
	local normalizedAttackerDir = attackerDirection % 16
	local normalizedTargetDir = targetDirection % 16

	-- Calculate the difference between the directions
	local diff = math.abs(normalizedAttackerDir - normalizedTargetDir)

	-- Check if the attacker is flanking
	-- The attacker is flanking if:
		-- The difference between the directions is 1 (clockwise)
		-- The difference between the directions is 15 (counterclockwise, equivalent to -1)
		-- The difference between the directions is 2 (clockwise)
		-- The difference between the directions is 14 (counterclockwise, equivalent to -2)
		-- The attacker is directly behind the target (both facing the same direction)
	return diff == 1 or diff == 2 or diff == 14 or diff == 15 or normalizedAttackerDir == normalizedTargetDir
end

