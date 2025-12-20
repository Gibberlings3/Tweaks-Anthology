--[[
+-----------------------------------------------------+
| cdtweaks, Standardize buying markup for all stores  |
+-----------------------------------------------------+
--]]

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if action.m_actionID == 150 then -- StartStore()
		local store = EEex_Resource_Demand(action.m_string1.m_pchData:get(), "STO") -- CStoreFileHeader
		--
		if store then -- sanity check
			-- if not container...
			if store.m_nStoreType ~= 5 then
				-- check if random mode
				if %random_mode% then
					math.randomseed(GT_Utility_DJB2(action.m_string1.m_pchData:get() .. tostring(EEex_GameState_GetGlobalInt("gtMasterGameSeed"))))
				end
				-- sell markup
				store.m_nBuyMarkUp = math.random(%sell_markup_min%, %sell_markup_max%)
				-- buy markup
				store.m_nSellMarkDown = math.random(%buy_markup_min%, %buy_markup_max%)
				-- ``math.randomseed()`` modifies the global state of the random number generator
				-- "Reset" to the default unpredictable behavior (the following should create a very high-precision, unpredictable number)
				if %random_mode% then
					local preciseSeed = (os.time() * 1000) + (os.clock() * 1000000)
					math.randomseed(preciseSeed)
				end
			end
		end
	end
end)

