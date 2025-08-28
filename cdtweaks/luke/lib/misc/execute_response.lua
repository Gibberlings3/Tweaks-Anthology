--[[
+---------------------------------------------------------------------------------------------------------------+
| "Custom" ``EEex_Action_ParseResponseString()`` + ``EEex_Action_ExecuteScriptFileResponseAsAIBaseInstantly()`` |
+---------------------------------------------------------------------------------------------------------------+
--]]

GT_ExecuteResponse = {

	["parseResponseString"] = function(source, target, string, scriptingTarget)
		if target then
			source:setStoredScriptingTarget(scriptingTarget, target)
		end
		local responseString = EEex_Action_ParseResponseString(string)
		--
		responseString:executeResponseAsAIBaseInstantly(source)
		responseString:free()
	end,

}

