--[[
+------------------------------------+
| check if an array contains a value |
+------------------------------------+
--]]

function GT_Utility_ArrayContains(array, value)
	for _, v in ipairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

