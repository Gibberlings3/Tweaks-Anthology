-- cdtweaks: NWN-ish metamagic feat for spellcasters (alter effects delivered by the spell accordingly) --

GTMMAGIC = {
	["typeMutator"] = function(context) -- this kicks in as soon as the projectile is created
		local CGameSprite = context["originatingSprite"]
		local metamagicArray = {"CDMTMQCK", "CDMTMEMP", "CDMTMEXT", "CDMTMMAX"}
		local metamagicType = EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])
		--
		if metamagicType > 0 then
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = metamagicArray[metamagicType],
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end,

	["projectileMutator"] = function(context)
		local projectile = context["projectile"] -- CProjectile
		local CGameSprite = context["originatingSprite"]
		local metamagicType = EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])
		--
		if EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) and metamagicType == 3 then
			projectile.m_nRepetitionCount = projectile.m_nRepetitionCount * 2
		end
	end,

	["effectMutator"] = function(context)
		local CGameEffect = context["effect"]
		local CGameSprite = context["originatingSprite"]
		local metamagicType = EEex_Sprite_GetStat(CGameSprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])
		local projectile = context["projectile"] -- CProjectile
		--
		if metamagicType == 2 then -- EMPOWER
			if CGameEffect.m_effectId == 0xC -- Damage (12)
				or CGameEffect.m_effectId == 0x11 -- Current HP bonus (17)
				or CGameEffect.m_effectId == 0x12 -- Max HP bonus (18)
				or CGameEffect.m_effectId == 0x7F -- Summon Monsters (127)
				or CGameEffect.m_effectId == 0x14B -- Summon Monsters 2 (331)
			then
				if CGameEffect.m_effectAmount > 1 then
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				elseif CGameEffect.m_diceSize > 1 then
					CGameEffect.m_diceSize = CGameEffect.m_diceSize + math.floor(CGameEffect.m_diceSize / 2)
				end
			end
			--
			if CGameEffect.m_effectId == 0x1 -- APR bonus (1)
				or CGameEffect.m_effectId == 0x6 -- CHR bonus (6)
				or CGameEffect.m_effectId == 0xA -- CON bonus (10)
				or CGameEffect.m_effectId == 0xF -- DEX bonus (15)
				or CGameEffect.m_effectId == 0x13 -- INT bonus (19)
				or CGameEffect.m_effectId == 0x15 -- Lore bonus (21)
				or CGameEffect.m_effectId == 0x16 -- Luck bonus (22)
				or CGameEffect.m_effectId == 0x17 -- Morale bonus (23)
				or CGameEffect.m_effectId == 0x1B -- Acid resistance bonus (27)
				or CGameEffect.m_effectId == 0x1C -- Cold resistance bonus (28)
				or CGameEffect.m_effectId == 0x1D -- Electricity resistance bonus (29)
				or CGameEffect.m_effectId == 0x1E -- Fire resistance bonus (30)
				or CGameEffect.m_effectId == 0x1F -- Magic damage resistance bonus (31)
				or CGameEffect.m_effectId == 0x2C -- Strength bonus (44)
				or CGameEffect.m_effectId == 0x31 -- Wisdom bonus (49)
				or CGameEffect.m_effectId == 0x36 -- Base THAC0 bonus (54)
				or CGameEffect.m_effectId == 0x3B -- Move silently bonus (59)
				or CGameEffect.m_effectId == 0x49 -- Attack damage bonus (73)
				or CGameEffect.m_effectId == 0x54 -- Magical fire resistance bonus (84)
				or CGameEffect.m_effectId == 0x55 -- Magical cold resistance bonus (85)
				or CGameEffect.m_effectId == 0x56 -- Slashing resistance bonus (86)
				or CGameEffect.m_effectId == 0x57 -- Crushing resistance bonus (87)
				or CGameEffect.m_effectId == 0x58 -- Piercing resistance bonus (88)
				or CGameEffect.m_effectId == 0x59 -- Missile resistance bonus (89)
				or CGameEffect.m_effectId == 0x5A -- Open locks bonus (90)
				or CGameEffect.m_effectId == 0x5B -- Find traps bonus (91)
				or CGameEffect.m_effectId == 0x5C -- Pick pockets bonus (92)
				or CGameEffect.m_effectId == 0x5D -- Fatigue bonus (93)
				or CGameEffect.m_effectId == 0x5E -- Intoxication bonus (94)
				or CGameEffect.m_effectId == 0x5F -- Tracking bonus (95)
				or CGameEffect.m_effectId == 0x60 -- Change level (96)
				or CGameEffect.m_effectId == 0x61 -- Exceptional strength bonus (97)
				or CGameEffect.m_effectId == 0x68 -- XP bonus (104)
				or CGameEffect.m_effectId == 0x69 -- Remove gold (105)
				or CGameEffect.m_effectId == 0x6A -- Morale break (106)
				or CGameEffect.m_effectId == 0x6C -- Reputation bonus (108)
				or CGameEffect.m_effectId == 0xA7 -- Missile THAC0 bonus (167)
				or CGameEffect.m_effectId == 0x107 -- Backstab bonus (263)
				or CGameEffect.m_effectId == 0x113 -- Hide in shadows bonus (275)
				or CGameEffect.m_effectId == 0x114 -- Detect illusion bonus (276)
				or CGameEffect.m_effectId == 0x115 -- Set traps bonus (277)
				or CGameEffect.m_effectId == 0x116 -- THAC0 bonus (278)
				or CGameEffect.m_effectId == 0x119 -- Wild surge bonus (281)
				or CGameEffect.m_effectId == 0x11C -- Melee THAC0 bonus (284)
				or CGameEffect.m_effectId == 0x11D -- Melee weapon damage bonus (285)
				or CGameEffect.m_effectId == 0x11E -- Missile weapon damage bonus (286)
				or CGameEffect.m_effectId == 0x120 -- Fist THAC0 bonus (288)
				or CGameEffect.m_effectId == 0x121 -- Fist damage bonus (289)
				or CGameEffect.m_effectId == 0x131 -- Off-hand THAC0 bonus (305)
				or CGameEffect.m_effectId == 0x132 -- Main hand THAC0 bonus (306)
				or CGameEffect.m_effectId == 0x143 -- Turn undead level (323)
				or CGameEffect.m_effectId == 0x15A -- Save vs. school bonus (346)
			then
				if CGameEffect.m_dWFlags == 0 then -- mode: increment
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				elseif CGameEffect.m_dWFlags == 2 then -- mode: set %
					if CGameEffect.m_effectAmount ~= 100 then
						if CGameEffect.m_effectAmount > 100 then
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
						else
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount - math.floor(CGameEffect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if CGameEffect.m_effectId == 0x2A -- Bonus wizard spells (42)
				or CGameEffect.m_effectId == 0x3C -- Casting failure (60)
				or CGameEffect.m_effectId == 0x3E -- Bonus priest spells (62)
				or CGameEffect.m_effectId == 0x6F -- Create weapon (111)
				or CGameEffect.m_effectId == 0x7A -- Create inventory item (122)
				or CGameEffect.m_effectId == 0x7F -- Summon Monsters (127)
				or CGameEffect.m_effectId == 0x81 -- Aid (non-cumulative) (129)
				or CGameEffect.m_effectId == 0x82 -- Bless (non-cumulative) (130)
				or CGameEffect.m_effectId == 0x83 -- Chant (non-cumulative) (131)
				or CGameEffect.m_effectId == 0x84 -- Draw upon holy might (non-cumulative) (132)
				or CGameEffect.m_effectId == 0x85 -- Luck (non-cumulative) (133)
				or CGameEffect.m_effectId == 0x89 -- Bad chant (non-cumulative) (137)
				or CGameEffect.m_effectId == 0x9F -- Mirror image effect (159)
				or CGameEffect.m_effectId == 0xA6 -- Magic resistance bonus (166)
				or CGameEffect.m_effectId == 0xAD -- Poison resistance bonus (173)
				or CGameEffect.m_effectId == 0xBE -- Increase attack speed factor (190)
				or CGameEffect.m_effectId == 0xBF -- Casting level bonus (191)
				or CGameEffect.m_effectId == 0xC8 -- Spell turning (200)
				or CGameEffect.m_effectId == 0xC9 -- Spell deflection (201)
				or CGameEffect.m_effectId == 0xD8 -- Level drain (216)
				or CGameEffect.m_effectId == 0xDC -- Remove spell school protections (220)
				or CGameEffect.m_effectId == 0xDD -- Remove spell type protections (221)
				or CGameEffect.m_effectId == 0xDE -- Teleport field (222)
				or CGameEffect.m_effectId == 0xDF -- Spell school deflection (223)
				or CGameEffect.m_effectId == 0xE2 -- Spell type deflection (226)
				or CGameEffect.m_effectId == 0xE3 -- Spell school turning (227)
				or CGameEffect.m_effectId == 0xE4 -- Spell type turning (228)
				or CGameEffect.m_effectId == 0xE5 -- Remove protection by school (229)
				or CGameEffect.m_effectId == 0xE6 -- Remove protection by type (230)
				or CGameEffect.m_effectId == 0xEA -- Create contingency (234)
				or CGameEffect.m_effectId == 0xEB -- Wing buffet (235)
				or CGameEffect.m_effectId == 0xF3 -- Drain item charges (243)
				or CGameEffect.m_effectId == 0xF4 -- Drain wizard spells (244)
				or CGameEffect.m_effectId == 0xFA -- Maximum damage each hit (250)
				or CGameEffect.m_effectId == 0xFF -- Create item (days) (255)
				or CGameEffect.m_effectId == 0x101 -- Create spell sequencer (257)
				or CGameEffect.m_effectId == 0x103 -- Spell trap (259)
				or CGameEffect.m_effectId == 0x106 -- Visual range bonus (262)
				or CGameEffect.m_effectId == 0x10D -- Shake screen (269)
				or CGameEffect.m_effectId == 0x12D -- Critical hit bonus (301)
				or CGameEffect.m_effectId == 0x149 -- Slow poison (329)
				or CGameEffect.m_effectId == 0x14C -- Attack damage type bonus (332)
				or CGameEffect.m_effectId == 0x16A -- Critical miss bonus (362)
			then
				CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
			end
			--
			if CGameEffect.m_effectId == 0x63 then -- Modify duration (99)
				if CGameEffect.m_effectAmount ~= 100 then
					if CGameEffect.m_effectAmount > 100 then
						CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
					else
						CGameEffect.m_effectAmount = CGameEffect.m_effectAmount - math.floor(CGameEffect.m_effectAmount / 2)
					end
				end
			end
			--
			if CGameEffect.m_effectId == 0x7E -- Movement rate bonus (126)
				or CGameEffect.m_effectId == 0xB0 -- Movement rate bonus 2 (176)
			then
				if CGameEffect.m_dWFlags == 0 then -- mode: increment
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				elseif CGameEffect.m_dWFlags == 2 or CGameEffect.m_dWFlags == 5 then -- mode: set % / set multiplicative %
					if CGameEffect.m_effectAmount ~= 100 then
						if CGameEffect.m_effectAmount > 100 then
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
						else
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount - math.floor(CGameEffect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if CGameEffect.m_effectId == 0x0 then -- AC bonus
				if EEex_IsBitSet(CGameEffect.m_dWFlags, 0x4) then -- mode: set base AC
					if CGameEffect.m_effectAmount > 10 then
						CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
					else
						if CGameEffect.m_effectAmount >= 0 then
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount - math.floor(CGameEffect.m_effectAmount / 2)
						else
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
						end
					end
				else
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				end
			end
			--
			if CGameEffect.m_effectId == 0x21 -- Save vs. death bonus (33)
				or CGameEffect.m_effectId == 0x22 -- Save vs. wand bonus (34)
				or CGameEffect.m_effectId == 0x23 -- Save vs. polymorph bonus (35)
				or CGameEffect.m_effectId == 0x24 -- Save vs. breath bonus (36)
				or CGameEffect.m_effectId == 0x25 -- Save vs. spell bonus (37)
				or CGameEffect.m_effectId == 0x145 -- All saving throws bonus (325)
			then
				if CGameEffect.m_dWFlags == 0 or CGameEffect.m_dWFlags == 3 then -- mode: increment / increment instantaneously
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				elseif CGameEffect.m_dWFlags == 2 then -- mode: set %
					if CGameEffect.m_effectAmount ~= 100 then
						if CGameEffect.m_effectAmount > 100 then
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
						else
							CGameEffect.m_effectAmount = CGameEffect.m_effectAmount - math.floor(CGameEffect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if CGameEffect.m_effectId == 0xDA then -- Stoneskin (218)
				if CGameEffect.m_dWFlags == 1 then -- use dice
					if CGameEffect.m_effectAmount > 1 then
						CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
					elseif CGameEffect.m_diceSize > 1 then
						CGameEffect.m_diceSize = CGameEffect.m_diceSize + math.floor(CGameEffect.m_diceSize / 2)
					end
				else
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + math.floor(CGameEffect.m_effectAmount / 2)
				end
			end
			--
			if CGameEffect.m_effectId == 0x14D then -- Static charge (333)
				CGameEffect.m_dWFlags = CGameEffect.m_dWFlags + math.floor(CGameEffect.m_dWFlags / 2) -- increase spell level by 50%
			end
		------------------------------------------------------------------------------
		elseif metamagicType == 3 then -- EXTEND
			if not EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) then
				if CGameEffect.m_effectId == 0x14D then -- Static charge (333)
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount * 2 -- # hits
				else
					if CGameEffect.m_durationType == 0 -- limited (seconds)
						or CGameEffect.m_durationType == 3 -- delay/limited (seconds)
						or CGameEffect.m_durationType == 4 -- delay/permanent (seconds)
						or CGameEffect.m_durationType == 10 -- limited (ticks)
					then
						CGameEffect.m_duration = CGameEffect.m_duration * 2
					end
				end
			end
		---------------------------------------------------------------------------------
		elseif metamagicType == 4 then -- MAXIMIZE
			if CGameEffect.m_effectId == 0xC -- Damage
				or CGameEffect.m_effectId == 0x11 -- Current HP bonus (17)
				or CGameEffect.m_effectId == 0x12 -- Max HP bonus (18)
				or CGameEffect.m_effectId == 0x7F -- Summon Monsters (127)
				or CGameEffect.m_effectId == 0x14B -- Summon Monsters 2 (331)
			then
				CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + CGameEffect.m_numDice * CGameEffect.m_diceSize
				CGameEffect.m_diceSize = 0
				CGameEffect.m_numDice = 0
			end
			if CGameEffect.m_effectId == 0xDA then -- Stoneskin (218)
				if CGameEffect.m_dWFlags == 1 then -- mode: use dice values
					CGameEffect.m_effectAmount = CGameEffect.m_effectAmount + CGameEffect.m_numDice * CGameEffect.m_diceSize
					CGameEffect.m_diceSize = 0
					CGameEffect.m_numDice = 0
				end
			end
			if CGameEffect.m_effectId == 0x14D then -- Static charge (333)
				CGameEffect.m_dWFlags = 0xFFFF -- max unsigned value (65535)
			end
		end
	end
}
