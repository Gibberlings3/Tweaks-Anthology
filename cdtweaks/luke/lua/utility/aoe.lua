-- checks if the targeted creature is within a cone of width X (in degrees) and radius Y (see f.i. Cone of Cold) --
-- should also work for full circles (see f.i. Fireball)

function GT_Sprite_IsWithinAoE(ox, oy, tx, ty, coneDir, coneWidth, radius)

	--[[
		- There are 16 possible directions (from 0 to 15, see "dir.ids")
		- A full circle is 360 degrees
		- Each direction step covers an angle of: 360° / 16 = 22.5°
	--]]

	-- Convert ``coneDir`` (direction step) to degrees
	local coneDirDeg = (coneDir % 16) * 22.5

	-- Calculate the angle from the origin to the target (in degrees)
	local dx = tx - ox
	local dy = ty - oy
	local angle = math.deg(math.atan2(dy, dx))
	if angle < 0 then angle = angle + 360 end

	-- Calculate angular difference (in degrees)
	local diff = math.abs(angle - coneDirDeg)
	if diff > 180 then diff = 360 - diff end

	--local distance = math.sqrt(dx*dx + dy*dy)
	local distance = GT_Utility_GetIsometricDistance(ox, oy, tx, ty)

	--[[
		- ``diff`` is the angular difference (in degrees) between the direction to the target and the center of the cone
		- ``coneWidth`` is the total width of the cone (in degrees)

		If your cone is centered at 90° (East) and has a width of 60°,
			- The cone covers from 60° to 120° (90° ± 30°)
			- Any target with an angle between 60° and 120° is inside the cone

		So, if the angular difference (``diff``) between the target and the center is ≤ 30° (``coneWidth / 2``), the target is inside the cone

		Why divide by 2?
			Because the cone's width is centered on the direction, so you want to allow half the width to the left and half to the right
	--]]

	return diff <= coneWidth / 2 and distance <= radius
end

