-- Returns ``true`` if the given sprite matched the value specified by the ``IDS Entry`` field, in the specified ``IDS File`` --

function GT_Sprite_CheckIDS(sprite, IDSEntry, IDSFile, checkFallen)
	local m_EnemyAlly = sprite.m_typeAI.m_EnemyAlly
	local m_General = sprite.m_typeAI.m_General
	local m_Race = sprite.m_typeAI.m_Race
	local m_Class = sprite.m_typeAI.m_Class
	local m_Specifics = sprite.m_typeAI.m_Specifics
	local m_Gender = sprite.m_typeAI.m_Gender
	local m_Alignment = sprite.m_typeAI.m_Alignment
	local m_nKit = sprite:getActiveStats().m_nKit
	--
	if IDSEntry == 0 then -- any value is a match
		return true
	end
	--
	if not checkFallen or type(checkFallen) ~= "boolean" then
		checkFallen = false
	end
	--
	if IDSFile == 2 then -- EA
		if IDSEntry == 30 then -- GOODCUTOFF
			return m_EnemyAlly < 30
		elseif IDSEntry == 200 then -- EVILCUTOFF
			return m_EnemyAlly > 200
		else
			return m_EnemyAlly == IDSEntry
		end
	elseif IDSFile == 3 then -- GENERAL
		return m_General == IDSEntry
	elseif IDSFile == 4 then -- RACE
		return m_Race == IDSEntry
	elseif IDSFile == 5 then -- CLASS
		local m_nLevel1 = sprite:getActiveStats().m_nLevel1
		local m_nLevel2 = sprite:getActiveStats().m_nLevel2
		local m_flags = sprite.m_baseStats.m_flags
		--
		if IDSEntry == 202 then -- MAGE_ALL
			return m_Class == 1 or -- MAGE
				m_Class == 10 or -- FIGHTER_MAGE_THIEF
				m_Class == 17 or -- FIGHTER_MAGE_CLERIC
				m_Class == 19 or -- SORCERER
				(m_Class == 7 and (EEex_IsBitUnset(m_flags, 0x4) or m_nLevel1 > m_nLevel2)) or -- FIGHTER_MAGE
				(m_Class == 13 and (EEex_IsBitUnset(m_flags, 0x4) or m_nLevel2 > m_nLevel1)) or -- MAGE_THIEF
				(m_Class == 14 and (EEex_IsBitUnset(m_flags, 0x4) or m_nLevel1 > m_nLevel2)) -- CLERIC_MAGE
		elseif IDSEntry == 203 then -- FIGHTER_ALL
			return m_Class == 2 or -- FIGHTER
				m_Class == 10 or -- FIGHTER_MAGE_THIEF
				m_Class == 17 or -- FIGHTER_MAGE_CLERIC
				m_Class == 20 or -- MONK
				(m_Class == 7 and (EEex_IsBitUnset(m_flags, 0x3) or m_nLevel2 > m_nLevel1)) or -- FIGHTER_MAGE
				(m_Class == 8 and (EEex_IsBitUnset(m_flags, 0x3) or m_nLevel2 > m_nLevel1)) or -- FIGHTER_CLERIC
				(m_Class == 9 and (EEex_IsBitUnset(m_flags, 0x3) or m_nLevel2 > m_nLevel1)) or -- FIGHTER_THIEF
				(m_Class == 16 and (EEex_IsBitUnset(m_flags, 0x3) or m_nLevel2 > m_nLevel1)) -- FIGHTER_DRUID
		elseif IDSEntry == 204 then -- CLERIC_ALL
			return m_Class == 3 or -- CLERIC
				m_Class == 17 or -- FIGHTER_MAGE_CLERIC
				(m_Class == 8 and (EEex_IsBitUnset(m_flags, 0x5) or m_nLevel1 > m_nLevel2)) or -- FIGHTER_CLERIC
				(m_Class == 14 and (EEex_IsBitUnset(m_flags, 0x5) or m_nLevel2 > m_nLevel1)) or -- CLERIC_MAGE
				(m_Class == 15 and (EEex_IsBitUnset(m_flags, 0x5) or m_nLevel2 > m_nLevel1)) or -- CLERIC_THIEF
				(m_Class == 18 and (EEex_IsBitUnset(m_flags, 0x5) or m_nLevel2 > m_nLevel1)) -- CLERIC_RANGER
		elseif IDSEntry == 205 then -- THIEF_ALL
			return m_Class == 4 or -- THIEF
				m_Class == 10 or -- FIGHTER_MAGE_THIEF
				(m_Class == 9 and (EEex_IsBitUnset(m_flags, 0x6) or m_nLevel1 > m_nLevel2)) or -- FIGHTER_THIEF
				(m_Class == 13 and (EEex_IsBitUnset(m_flags, 0x6) or m_nLevel1 > m_nLevel2)) or -- MAGE_THIEF
				(m_Class == 15 and (EEex_IsBitUnset(m_flags, 0x6) or m_nLevel1 > m_nLevel2)) -- CLERIC_THIEF
		elseif IDSEntry == 206 then -- BARD_ALL
			return m_Class == 5 -- BARD
		elseif IDSEntry == 207 then -- PALADIN_ALL
			return m_Class == 6 and (not checkFallen or EEex_IsBitUnset(m_flags, 0x9)) -- PALADIN
		elseif IDSEntry == 208 then -- DRUID_ALL
			return m_Class == 11 or -- DRUID
				(m_Class == 16 and (EEex_IsBitUnset(m_flags, 0x7) or m_nLevel1 > m_nLevel2)) -- FIGHTER_DRUID
		elseif IDSEntry == 209 then -- RANGER_ALL
			return (m_Class == 12 or -- RANGER
				(m_Class == 18 and (EEex_IsBitUnset(m_flags, 0x8) or m_nLevel1 > m_nLevel2))) and -- CLERIC_RANGER
				(not checkFallen or EEex_IsBitUnset(m_flags, 10))
		else
			if IDSEntry == 6 then -- PALADIN
				return (m_Class == IDSEntry) and (not checkFallen or EEex_IsBitUnset(m_flags, 0x9))
			elseif IDSEntry == 12 then -- RANGER
				return (m_Class == IDSEntry) and (not checkFallen or EEex_IsBitUnset(m_flags, 10))
			else
				return m_Class == IDSEntry
			end
		end
	elseif IDSFile == 6 then -- SPECIFIC
		return m_Specifics == IDSEntry
	elseif IDSFile == 7 then -- GENDER
		return m_Gender == IDSEntry
	elseif IDSFile == 8 then -- ALIGN
		if IDSEntry == 0x1 then -- MASK_GOOD
			return m_Alignment == 0x11 or m_Alignment == 0x21 or m_Alignment == 0x31 -- LAWFUL_GOOD / NEUTRAL_GOOD / CHAOTIC_GOOD
		elseif IDSEntry == 0x2 then -- MASK_GENEUTRAL
			return m_Alignment == 0x21 or m_Alignment == 0x23 or m_Alignment == 0x22 -- NEUTRAL_GOOD / NEUTRAL_EVIL / NEUTRAL
		elseif IDSEntry == 0x3 then -- MASK_EVIL
			return m_Alignment == 0x13 or m_Alignment == 0x23 or m_Alignment == 0x33 -- LAWFUL_EVIL / NEUTRAL_EVIL / CHAOTIC_EVIL
		elseif IDSEntry == 0x10 then -- MASK_LAWFUL
			return m_Alignment == 0x11 or m_Alignment == 0x12 or m_Alignment == 0x13 -- LAWFUL_GOOD / LAWFUL_NEUTRAL / LAWFUL_EVIL
		elseif IDSEntry == 0x20 then -- MASK_LCNEUTRAL
			return m_Alignment == 0x12 or m_Alignment == 0x32 or m_Alignment == 0x22 -- LAWFUL_NEUTRAL / CHAOTIC_NEUTRAL / NEUTRAL
		elseif IDSEntry == 0x30 then -- MASK_CHAOTIC
			return m_Alignment == 0x31 or m_Alignment == 0x32 or m_Alignment == 0x33 -- CHAOTIC_GOOD / CHAOTIC_NEUTRAL / CHAOTIC_EVIL
		else
			return m_Alignment == IDSEntry
		end
	elseif IDSFile == 9 then -- KIT
		return m_nKit == IDSEntry
	end
	--
	return false
end

