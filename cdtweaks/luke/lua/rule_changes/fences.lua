--[[
+------------------------------------------------------------------------+
| cdtweaks, Disable stealing at fences. Reputation doesn't affect prices |
+------------------------------------------------------------------------+
--]]

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	if action.m_actionID == 150 then -- StartStore()
		local store = EEex_Resource_Demand(action.m_string1.m_pchData:get(), "STO") -- CStoreFileHeader
		--
		if store then -- sanity check
			-- if can buy fenced goods...
			if EEex_IsBitSet(store.m_nStoreFlags, 12) then
				-- disable stealing
				store.m_nStoreFlags = EEex_UnsetBit(store.m_nStoreFlags, 0x3)
				-- make sure reputation does not affect prices
				store.m_nStoreFlags = EEex_SetBit(store.m_nStoreFlags, 13)
			end
		end
	end
end)

