--[[
+----------------------+
| Thorn Whip (cantrip) |
+----------------------+
--]]

-- Pulls the targeted creature closer to the caster --

function %CLERIC_THORN_WHIP%(CGameEffect, CGameSprite)
	local wingBuffetImmunity = "EEex_IsImmuneToOpcode(Myself,235)"
	--
	local targetAnimateStr = GT_Resource_IDSToSymbol["animate"][CGameSprite.m_animation.m_animation.m_animationID]
	--local targetGeneralStr = GT_Resource_IDSToSymbol["general"][CGameSprite.m_typeAI.m_General]
	local targetPersonalSpace = EEex_Sprite_GetPersonalSpace(CGameSprite)
	--
	local animate = {
		["TANARRI"] = true,
		["DRAGON_RED"] = true,
		["DRAGON_BLACK"] = true,
		["DRAGON_SILVER"] = true,
		["DRAGON_GREEN"] = true,
		["DRAGON_AQUA"] = true,
		["DRAGON_BLUE"] = true,
		["DRAGON_BROWN"] = true,
		["DRAGON_MULTICOLOR"] = true,
		["DRAGON_PURPLE"] = true,
		["DEMOGORGON"] = true,
		["ELEMENTAL_EARTH"] = true,
		["SHAMBLING_MOUND"] = true,
		["ELEMENTAL_FIRE"] = true,
		["ELEMENTAL_FIRE_PURPLE"] = true,
		["BURNING_MAN"] = true,
		["ELEMENTAL_AIR"] = true,
		["RAVER"] = true,
		["SLAYER"] = true,
		["SOLAR"] = true,
		["DEVA_MONADIC"] = true,
		["MELISSAN"] = true,
		["GIANT_FIRE"] = true,
		["GIANT_YAGA-SHURA"] = true,
		["GOLEM_ICE"] = true,
	}
	--
	if not animate[targetAnimateStr] then
		if targetPersonalSpace <= 3 then
			if not GT_EvalConditional["parseConditionalString"](CGameSprite, nil, wingBuffetImmunity) then
				CGameSprite:applyEffect({
					["effectID"] = 235, -- wing buffet
					["dwFlags"] = 4, -- mode: Towards source
					["effectAmount"] = 20,
					["duration"] = 2,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
				CGameSprite:applyEffect({
					["effectID"] = 39, -- sleep
					["dwFlags"] = 1, -- do not wake sleepers
					["duration"] = 3,
					["savingThrow"] = 0x800000, -- bypass op101
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
end

