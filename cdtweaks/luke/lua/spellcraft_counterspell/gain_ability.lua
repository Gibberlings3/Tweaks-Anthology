-- Give feat --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or GT_Globals_IsChargenOrStartMenu[Infinity_GetCurrentScreenName()] then
		return
	end
	-- internal function that grants the actual feat
	local gain = function()
		-- Mark the creature as 'feat granted'
		sprite:setLocalInt("gtNWNCounterSpell", 1)
		--
		if sprite.m_typeAI.m_Class ~= 5 then -- skip bards
			sprite:applyEffect({
				["effectID"] = 172, -- Remove spell
				["res"] = "%INNATE_COUNTERSPELL%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
			sprite:applyEffect({
				["effectID"] = 171, -- Give spell
				["res"] = "%INNATE_COUNTERSPELL%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / flags
	local class = GT_Resource_SymbolToIDS["class"]
	-- Check if spellcaster class -- single/multi/(complete)dual
	local isClericAll = GT_Sprite_CheckIDS(sprite, class["CLERIC_ALL"], 5)
	local isMageAll = GT_Sprite_CheckIDS(sprite, class["MAGE_ALL"], 5)
	local isDruidAll = GT_Sprite_CheckIDS(sprite, class["DRUID_ALL"], 5)
	local isShaman = GT_Sprite_CheckIDS(sprite, class["SHAMAN"], 5)
	local isBardAll = GT_Sprite_CheckIDS(sprite, class["BARD_ALL"], 5)
	--
	local gainAbility = isClericAll or isMageAll or isDruidAll or isShaman or isBardAll
	--
	if sprite:getLocalInt("gtNWNCounterSpell") == 0 then
		if gainAbility then
			gain()
		end
	else
		if gainAbility then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNCounterSpell", 0)
			--
			if sprite:getLocalInt("gtNWNCounterSpellMode") == 1 then
				sprite:applyEffect({
					["effectID"] = 146, -- Cast spell
					["dwFlags"] = 1, -- instant/ignore level
					["res"] = "%INNATE_COUNTERSPELL%Z",
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			end
			--
			sprite:applyEffect({
				["effectID"] = 172, -- Remove spell
				["res"] = "%INNATE_COUNTERSPELL%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
