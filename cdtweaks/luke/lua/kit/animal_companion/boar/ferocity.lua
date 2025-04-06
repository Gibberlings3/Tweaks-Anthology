--[[
+---------------------------------------------------------------------------------------------------------+
| Animal Ferocity: The creature using this ability becomes ferocious for 5 rounds (+1 round per 5 levels) |
+---------------------------------------------------------------------------------------------------------+
| Specs:                                                                                                  |
| - berserk                                                                                               |
| - +1d6 STR                                                                                              |
| - +1d6 CON                                                                                              |
| - movement rate doubled                                                                                 |
| - immunity to confusion, charm, and feeblemind                                                          |
+---------------------------------------------------------------------------------------------------------+
--]]

function %INNATE_ANIMAL_FEROCITY%(CGameEffect, CGameSprite)
	local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local levelModifier = math.floor(spriteActiveStats.m_nLevel1 / 5) -- +1 round every 5 levels
	--
	local berserkImmunity = EEex_Trigger_ParseConditionalString("EEex_IsImmuneToOpcode(Myself,3)")
	--
	if not berserkImmunity:evalConditionalAsAIBase(CGameSprite) then
		local effectCodes = {
			{["op"] = 3}, -- berserk (mode: normal)
			{["op"] = 44, ["p1"] = math.random(6)}, -- STR mod (+1d6)
			{["op"] = 10, ["p1"] = math.random(6)}, -- CON mod (+1d6)
			{["op"] = 317, ["p2"] = 2}, -- Haste (movement rate only)
			{["op"] = 403, ["p1"] = 0x42002, ["res"] = "GTIMMUNE"}, -- screen effects (confusion, charm, feeblemind)
			{["op"] = 142, ["p2"] = 4} -- icon: Berserk
			{["op"] = 206, ["res"] = CGameEffect.m_sourceRes:get(), ["p1"] = %feedback_strref_already_cast%}, -- protection from spell
		}
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["effectAmount"] = attributes["p1"] or 0,
				["dwFlags"] = attributes["p2"] or 0,
				["res"] = attributes["res"] or "",
				["duration"] = (6 * 5) + (6 * levelModifier),
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
	end
	--
	berserkImmunity:free()
end
