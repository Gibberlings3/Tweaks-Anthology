-- checks if the targeted creature is within a cone of width X (in degrees) and radius Y (see f.i. Cone of Cold) --

local function isPtInArc(ptEdgeX, ptEdgeY, nCheckAngle, ptCheckX, ptCheckY)

	if ptCheckX == 0 and ptCheckY == 0 then
		return true
	end

	local nDotProduct = ptEdgeX * ptCheckX + ptEdgeY * ptCheckY

	local fEdgeMagnitude = math.sqrt(ptEdgeX * ptEdgeX + ptEdgeY * ptEdgeY)
	local fCheckMagnitude = math.sqrt(ptCheckX * ptCheckX + ptCheckY * ptCheckY)

	local fCosine = nDotProduct / (fEdgeMagnitude * fCheckMagnitude)

	local fClampedCosine = math.max(-1.0, math.min(fCosine, 1.0))
	local fRadians = math.acos(fClampedCosine)
	local nAngle = (fRadians * 180 / math.pi)

	return nAngle <= nCheckAngle / 2
end

function GT_Sprite_TestCone(angle, ox, oy, tx, ty, px, py)

	if angle <= 180 then
		-- Vector from cone source to target pos
		local nEdgeX = tx - ox
		local nEdgeY = ty - oy
		-- Vector from cone source to potential target object
		local nCheckX = px - ox
		local nCheckY = py - oy

		if isPtInArc(nEdgeX, nEdgeY, angle, nCheckX, nCheckY) then
			return true
		end
	else
		-- Vector from cone source to target pos
		local nEdgeX = ox - tx
		local nEdgeY = oy - ty
		-- Vector from cone source to potential target object
		local nCheckX = px - ox
		local nCheckY = py - oy

		if not isPtInArc(nEdgeX, nEdgeY, 360 - angle, nCheckX, nCheckY) then
			return true
		end
	end

	return false
end

