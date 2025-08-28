-- Check if a key exists in a table (should work for any kind of table, from simple to nested tables...) --

function GT_Utility_KeyExists(tbl, ...) -- NB.: ``...`` is called ``vararg`` (variable argument). It allows the function to accept a variable number of arguments. This is useful when we don't know in advance how many arguments will be passed to the function
	local keys = {...}
	local current = tbl

	for _, key in ipairs(keys) do
		if type(current) ~= "table" or current[key] == nil then
			return false
		end
		current = current[key]
	end

	return true
end

