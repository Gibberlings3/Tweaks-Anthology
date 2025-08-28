-- Check if the script runner is affected by effects from the specified resref --

function GT_LuaTrigger_ResRefCheck(resref)
	local toReturn = false
	--
	local func = function(effect)
		if effect.m_sourceRes:get() == resref then
			toReturn = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_timedEffectList, func)
	if not toReturn then
		-- guess we can safely ignore equipped effects, right...?
		--EEex_Utility_IterateCPtrList(EEex_LuaTrigger_Object.m_equipedEffectList, func)
	end
	--
	return toReturn
end

