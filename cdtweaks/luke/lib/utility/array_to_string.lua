-- Converts an array to a string representation --

function GT_Utility_ArrayToString(array)
	local result = {}
	for _, value in ipairs(array) do
		table.insert(result, tostring(value)) -- Convert each value to a string
	end
	return "{" .. table.concat(result, ", ") .. "}" -- Join the values with commas
end

