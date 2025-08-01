-- return true if the number of creatures of the type specified in sight of the active CRE are greater or equal to the specified number --

function GT_LuaTrigger_NumCreatureCheck(aiObjectTypeString, num)
	local creatures = EEex_Sprite_GetAllOfTypeStringInRange(EEex_LuaTrigger_Object, string.format("[%s]", aiObjectTypeString), EEex_LuaTrigger_Object:virtual_GetVisualRange(), nil, nil, nil)

	if #creatures >= num then
		return true
	else
		return math.random(num) <= #creatures -- scales with the number of expected creatures
	end

end

