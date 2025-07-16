--[[
+--------------------------------------------------------------------------------------+
| cdtweaks, automatically unsummon summoned creatures if the summoner dies prematurely |
+--------------------------------------------------------------------------------------+
--]]

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- Check creature's gender / state / resref / animationID / ea
	local spriteGenderStr = GT_Resource_IDSToSymbol["gender"][sprite.m_typeAI.m_Gender]
	local spriteEAStr = GT_Resource_IDSToSymbol["ea"][sprite.m_typeAI.m_EnemyAlly]
	local spriteAnimateStr = GT_Resource_IDSToSymbol["animate"][sprite.m_animation.m_animation.m_animationID]
	local spriteResRef = sprite.m_resref:get()
	--
	local summonerID = sprite.m_lSummonedBy.m_Instance
	local summonerSprite = EEex_GameObject_Get(summonerID)
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local summonerGeneralState
	if summonerSprite then
		summonerGeneralState = summonerSprite.m_derivedStats.m_generalState
	end
	--
	local normal = spriteGenderStr == "SUMMONED" or spriteGenderStr == "SUMMONED_DEMON"
	local hardcodedResRefs = {
		["PLANGOOD"] = true,
		["PLANEVIL"] = true,
		["DEVAGOOD"] = true,
		["DEVAEVIL"] = true,
		-- the resref field is clobbered after reload
		["*LANGOOD"] = true,
		["*LANEVIL"] = true,
		["*EVAGOOD"] = true,
		["*EVAEVIL"] = true,
	}
	local celestial = spriteGenderStr == "BOTH" and hardcodedResRefs[spriteResRef] and (spriteAnimateStr == "SOLAR" or spriteAnimateStr == "DEVA_MONADIC")
	--
	if spriteEAStr ~= "FAMILIAR" and summonerSprite and EEex_IsBitSet(summonerGeneralState, 11) and (normal or celestial) then
		sprite:applyEffect({
			["effectID"] = 68, -- Unsummon creature
			["durationType"] = 1,
			["effectAmount"] = 1, -- Show text notification
			["noSave"] = true,
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
end)

