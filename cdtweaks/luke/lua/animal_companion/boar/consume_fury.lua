-- cdtweaks, Animal Companion (Dire Boar): Consume all Fury to cause bleeding damage --

function GTACMP05(CGameEffect, CGameSprite)
	local furyAmount = CGameSprite:getLocalInt("gtAnmlCompBoarFuryAmount")
	local targetSprite = EEex_GameObject_Get(CGameSprite.m_targetId)
	--
	if furyAmount >= 100 then
		CGameSprite:setLocalInt("gtAnmlCompBoarFuryAmount", 0)
		-- prevent the boar from generating Fury during this attack
		EEex_GameObject_ApplyEffect(CGameSprite,
		{
			["effectID"] = 318, -- Protection from resource
			["res"] = "GTACP05A", -- + 5 Fury
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameEffect.m_sourceTarget,
		})
		EEex_GameObject_ApplyEffect(targetSprite,
		{
			["effectID"] = 318, -- Protection from resource
			["res"] = "GTACP05A", -- + 5 Fury
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameSprite.m_targetId,
		})
		-- actual spell causing bleeding damage
		EEex_GameObject_ApplyEffect(targetSprite,
		{
			["effectID"] = 146, -- Cast spell
			["durationType"] = 1,
			["dwFlags"] = 1, -- mode: Cast instantly (caster level)
			["res"] = "GTACP05B", -- spl file
			["sourceID"] = CGameEffect.m_sourceId,
			["sourceTarget"] = CGameSprite.m_targetId,
		})
	end
end
