--[[
+---------------------------------------------------------------------------------+
| Utility: ``damage_type`` (itm ability +0x1C) to ``op12*p2`` / AC type converter |
+---------------------------------------------------------------------------------+
--]]

function GT_Utility_DamageTypeConverter(damageType, CDerivedStats)
	-- none / crushing
	if damageType == 0 or damageType == 2 then
		return 0x0, CDerivedStats.m_nACCrushingMod
	-- piercing
	elseif damageType == 1 then
		return 0x10, CDerivedStats.m_nACPiercingMod
	-- slashing
	elseif damageType == 3 then
		return 0x100, CDerivedStats.m_nACSlashingMod
	-- missile
	elseif damageType == 4 then
		return 0x80, CDerivedStats.m_nACMissileMod
	-- non-lethal
	elseif damageType == 5 then
		return 0x800, CDerivedStats.m_nACCrushingMod
	-- piercing/crushing (better)
	elseif damageType == 6 then
		if CDerivedStats.m_nResistPiercing > CDerivedStats.m_nResistCrushing then
			return 0x0, CDerivedStats.m_nACCrushingMod
		else
			return 0x10, CDerivedStats.m_nACPiercingMod
		end
	-- piercing/slashing (better)
	elseif damageType == 7 then
		if CDerivedStats.m_nResistPiercing > CDerivedStats.m_nResistSlashing then
			return 0x100, CDerivedStats.m_nACSlashingMod
		else
			return 0x10, CDerivedStats.m_nACPiercingMod
		end
	-- slashing/crushing (worse)
	elseif damageType == 8 then
		if CDerivedStats.m_nResistCrushing > CDerivedStats.m_nResistSlashing then
			return 0x0, CDerivedStats.m_nACCrushingMod
		else
			return 0x100, CDerivedStats.m_nACSlashingMod
		end
	end
	--
	EEex_Error("invalid damage type: " .. damageType) -- should never happen
end
