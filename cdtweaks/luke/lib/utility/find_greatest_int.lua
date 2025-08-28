-- given an array of integers, return the greatest one --

function GT_Utility_FindGreatestInt(array)
	local greatest = array[1]
	for i = 2, #array do
		greatest = math.max(greatest, array[i])
	end
	return greatest
end

