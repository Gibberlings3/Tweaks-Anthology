-- cdtweaks, Animal Companion (bear): Last Stand passive ability --

function GTACMP01(op403CGameEffect, CGameEffect, CGameSprite)
	local damageTypeStr = GT_Resource_IDSToSymbol["dmgtype"][CGameEffect.m_dWFlags]
	local damageAmount = CGameEffect.m_effectAmount
	--
	local spriteHP = CGameSprite.m_baseStats.m_hitPoints
	--
	local spriteClass = CGameSprite.m_typeAI.m_Class
	local class = GT_Resource_SymbolToIDS["class"]
	--
	local roll = -1
	if spriteClass == class["BEAR_BROWN"] or spriteClass == class["BEAR_CAVE"] then
		roll = math.random(4) -- 1d4
	else
		roll = 1 + math.random(4) -- 1d4+1
	end
	-- After suffering fatal damage, the creature will continue fighting desperately for a short time, attacking friends and foes alike
	if CGameEffect.m_effectId == 0xC and damageTypeStr ~= "STUNNING" and CGameEffect.m_slotNum == -1 and CGameEffect.m_sourceType == 0 and CGameEffect.m_sourceRes:get() == "" then -- base weapon damage (all damage types but STUNNING)
		if damageAmount >= spriteHP then
			if EEex_Sprite_GetLocalInt(CGameSprite, "gtAnmlCompBearLastStand") == 0 then
				EEex_Sprite_SetLocalInt(CGameSprite, "gtAnmlCompBearLastStand", 1)
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 330, -- Floating text
					["durationType"] = 1,
					["effectAmount"] = %feedback_strref%,
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
				})
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 3, -- Berserk
					["duration"] = 6 * roll,
					["dwFlags"] = 1, -- Attack the nearest creature, no matter what
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
				})
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 176, -- Movement rate bonus 2
					["duration"] = 6 * roll,
					["dwFlags"] = 5, -- Mode: multiply %
					["effectAmount"] = 200,
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
				})
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 215, -- Play visual effect
					["duration"] = 2,
					["dwFlags"] = 1, -- Over target (attached)
					["res"] = "ICSTRENI",
					["sourceID"] = CGameSprite.m_id,
					["sourceTarget"] = CGameSprite.m_id,
				})
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 13, -- Automatically kill the creature after ``roll`` rounds
					["duration"] = 6 * roll,
					["dwFlags"] = 4, -- normal death
					["durationType"] = 4,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
			return true
		end
	end
end
