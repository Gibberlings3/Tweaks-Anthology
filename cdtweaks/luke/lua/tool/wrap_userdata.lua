--[[
+-------------------------------------------------------------------------------------------------------------------------------------+
| Wrap userdata with a metatable to handle field access and error                                                                     |
+-------------------------------------------------------------------------------------------------------------------------------------+
| In Lua, metamethods are special functions that start with double underscores (``__``)                                               |
| These are reserved names that Lua recognizes as metamethods, which define how certain operations are handled for tables or userdata |
+-------------------------------------------------------------------------------------------------------------------------------------+
--]]

function GT_LuaTool_WrapUserdata(ud)
	local mt = {
		__index = function(t, key)
			if ud[key] ~= nil then
				return ud[key]
			else
				EEex_Error("Attempt to access non-existent key: " .. tostring(key))
			end
		end,
	}
	return setmetatable({}, mt)
end
