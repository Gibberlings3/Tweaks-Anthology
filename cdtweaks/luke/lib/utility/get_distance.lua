-- Gets the distance between two points --

function GT_Utility_GetDistance(x1, y1, x2, y2)
	return math.floor((((x1 - x2) ^ 2) + ((y1 - y2) ^ 2)) ^ .5) 
end

function GT_Utility_GetIsometricDistance(x1, y1, x2, y2)
	return math.floor(((x1 - x2) ^ 2 + (4/3 * (y1 - y2)) ^ 2) ^ .5)
end

