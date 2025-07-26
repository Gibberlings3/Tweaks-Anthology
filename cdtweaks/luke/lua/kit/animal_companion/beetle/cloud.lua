--[[
+------------------------------------------------------------------------------------------------------------------+
| Bombardier Beetle Cloud: targeted creature is either stunned for 2d4 rounds or deafened for 2d6 rounds (no save) |
+------------------------------------------------------------------------------------------------------------------+
--]]

function %INNATE_BOMBARDIER_BEETLE_CLOUD%(CGameEffect, CGameSprite)
	local stunDuration = math.random(4) + math.random(4) -- 2d4
	local deafDuration = math.random(6) + math.random(6) -- 2d6
	--
	local stunImmunity = "EEex_IsImmuneToOpcode(Myself,45)"
	local deafImmunity = "EEex_IsImmuneToOpcode(Myself,80)"
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, stunImmunity) then
		if math.random(5) == 1 then -- 20% chance
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 45, -- Stun
				["duration"] = 6 * stunDuration,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display String
				["effectAmount"] = %feedback_strref_stun%,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
	--
	if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, deafImmunity) then
		if math.random(5) == 1 then -- 20% chance
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 80, -- Deafness
				["duration"] = 6 * deafDuration,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 142, -- Icon
				["duration"] = 6 * deafDuration,
				["dwFlags"] = 112,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 139, -- Display String
				["effectAmount"] = %feedback_strref_deaf%,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end
