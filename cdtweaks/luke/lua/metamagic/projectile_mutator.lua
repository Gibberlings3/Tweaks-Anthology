-- cdtweaks: NWN-ish metamagic feat for spellcasters (alter effects delivered by the spell accordingly) --

GTMMAGIC = {
	["typeMutator"] = function(context) -- this kicks in as soon as the projectile is created
		local originatingEffect = context["originatingEffect"] -- CGameEffect
		local originatingSprite = context["originatingSprite"] -- CGameSprite
		--
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Spell] = true,
			[EEex_Projectile_DecodeSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		--originatingEffect.m_done = true
		EEex_Utility_IterateCPtrList(originatingSprite.m_timedEffectList, function(effect)
			if effect.m_sourceRes:get() == "CDMMAGIC" then -- op408 / op232 (Silent Spell)
				effect.m_done = true
			end
		end)
	end,

	["projectileMutator"] = function(context)
		local projectile = context["projectile"] -- CProjectile
		local originatingEffect = context["originatingEffect"] -- CGameEffect
		--
		local actionSources = {
			[EEex_Projectile_DecodeSource.CGameSprite_Spell] = true,
			[EEex_Projectile_DecodeSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_DecodeSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.decodeSource] then
			return
		end
		--
		if EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) and originatingEffect.m_effectAmount == 3 then
			if projectile.m_nRepetitionCount > 1 then
				projectile.m_nRepetitionCount = projectile.m_nRepetitionCount * 2
			end
		end
	end,

	["effectMutator"] = function(context)
		local effect = context["effect"] -- CGameEffect
		local originatingEffect = context["originatingEffect"] -- CGameEffect
		local projectile = context["projectile"] -- CProjectile
		--
		local actionSources = {
			[EEex_Projectile_AddEffectSource.CGameSprite_Spell] = true,
			[EEex_Projectile_AddEffectSource.CGameSprite_SpellPoint] = true,
			[EEex_Projectile_AddEffectSource.CGameAIBase_ForceSpell] = true,
			[EEex_Projectile_AddEffectSource.CGameAIBase_ForceSpellPoint] = true,
		}
		--
		if not actionSources[context.addEffectSource] then
			return
		end
		--
		if originatingEffect.m_effectAmount == 2 then -- EMPOWER
			if effect.m_effectId == 0xC -- Damage (12)
				or effect.m_effectId == 0x11 -- Current HP bonus (17)
				or effect.m_effectId == 0x12 -- Max HP bonus (18)
				or effect.m_effectId == 0x7F -- Summon Monsters (127)
				or effect.m_effectId == 0x14B -- Summon Monsters 2 (331)
			then
				if effect.m_effectAmount > 1 then
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				elseif effect.m_diceSize > 1 then
					effect.m_diceSize = effect.m_diceSize + math.floor(effect.m_diceSize / 2)
				end
			end
			--
			if effect.m_effectId == 0x1 -- APR bonus (1)
				or effect.m_effectId == 0x6 -- CHR bonus (6)
				or effect.m_effectId == 0xA -- CON bonus (10)
				or effect.m_effectId == 0xF -- DEX bonus (15)
				or effect.m_effectId == 0x13 -- INT bonus (19)
				or effect.m_effectId == 0x15 -- Lore bonus (21)
				or effect.m_effectId == 0x16 -- Luck bonus (22)
				or effect.m_effectId == 0x17 -- Morale bonus (23)
				or effect.m_effectId == 0x1B -- Acid resistance bonus (27)
				or effect.m_effectId == 0x1C -- Cold resistance bonus (28)
				or effect.m_effectId == 0x1D -- Electricity resistance bonus (29)
				or effect.m_effectId == 0x1E -- Fire resistance bonus (30)
				or effect.m_effectId == 0x1F -- Magic damage resistance bonus (31)
				or effect.m_effectId == 0x2C -- Strength bonus (44)
				or effect.m_effectId == 0x31 -- Wisdom bonus (49)
				or effect.m_effectId == 0x36 -- Base THAC0 bonus (54)
				or effect.m_effectId == 0x3B -- Move silently bonus (59)
				or effect.m_effectId == 0x49 -- Attack damage bonus (73)
				or effect.m_effectId == 0x54 -- Magical fire resistance bonus (84)
				or effect.m_effectId == 0x55 -- Magical cold resistance bonus (85)
				or effect.m_effectId == 0x56 -- Slashing resistance bonus (86)
				or effect.m_effectId == 0x57 -- Crushing resistance bonus (87)
				or effect.m_effectId == 0x58 -- Piercing resistance bonus (88)
				or effect.m_effectId == 0x59 -- Missile resistance bonus (89)
				or effect.m_effectId == 0x5A -- Open locks bonus (90)
				or effect.m_effectId == 0x5B -- Find traps bonus (91)
				or effect.m_effectId == 0x5C -- Pick pockets bonus (92)
				or effect.m_effectId == 0x5D -- Fatigue bonus (93)
				or effect.m_effectId == 0x5E -- Intoxication bonus (94)
				or effect.m_effectId == 0x5F -- Tracking bonus (95)
				or effect.m_effectId == 0x60 -- Change level (96)
				or effect.m_effectId == 0x61 -- Exceptional strength bonus (97)
				or effect.m_effectId == 0x68 -- XP bonus (104)
				or effect.m_effectId == 0x69 -- Remove gold (105)
				or effect.m_effectId == 0x6A -- Morale break (106)
				or effect.m_effectId == 0x6C -- Reputation bonus (108)
				or effect.m_effectId == 0xA7 -- Missile THAC0 bonus (167)
				or effect.m_effectId == 0x107 -- Backstab bonus (263)
				or effect.m_effectId == 0x113 -- Hide in shadows bonus (275)
				or effect.m_effectId == 0x114 -- Detect illusion bonus (276)
				or effect.m_effectId == 0x115 -- Set traps bonus (277)
				or effect.m_effectId == 0x116 -- THAC0 bonus (278)
				or effect.m_effectId == 0x119 -- Wild surge bonus (281)
				or effect.m_effectId == 0x11C -- Melee THAC0 bonus (284)
				or effect.m_effectId == 0x11D -- Melee weapon damage bonus (285)
				or effect.m_effectId == 0x11E -- Missile weapon damage bonus (286)
				or effect.m_effectId == 0x120 -- Fist THAC0 bonus (288)
				or effect.m_effectId == 0x121 -- Fist damage bonus (289)
				or effect.m_effectId == 0x131 -- Off-hand THAC0 bonus (305)
				or effect.m_effectId == 0x132 -- Main hand THAC0 bonus (306)
				or effect.m_effectId == 0x143 -- Turn undead level (323)
				or effect.m_effectId == 0x15A -- Save vs. school bonus (346)
			then
				if effect.m_dWFlags == 0 then -- mode: increment
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				elseif effect.m_dWFlags == 2 then -- mode: set %
					if effect.m_effectAmount ~= 100 then
						if effect.m_effectAmount > 100 then
							effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
						else
							effect.m_effectAmount = effect.m_effectAmount - math.floor(effect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if effect.m_effectId == 0x2A -- Bonus wizard spells (42)
				or effect.m_effectId == 0x3C -- Casting failure (60)
				or effect.m_effectId == 0x3E -- Bonus priest spells (62)
				or effect.m_effectId == 0x6F -- Create weapon (111)
				or effect.m_effectId == 0x7A -- Create inventory item (122)
				or effect.m_effectId == 0x7F -- Summon Monsters (127)
				or effect.m_effectId == 0x81 -- Aid (non-cumulative) (129)
				or effect.m_effectId == 0x82 -- Bless (non-cumulative) (130)
				or effect.m_effectId == 0x83 -- Chant (non-cumulative) (131)
				or effect.m_effectId == 0x84 -- Draw upon holy might (non-cumulative) (132)
				or effect.m_effectId == 0x85 -- Luck (non-cumulative) (133)
				or effect.m_effectId == 0x89 -- Bad chant (non-cumulative) (137)
				or effect.m_effectId == 0x9F -- Mirror image effect (159)
				or effect.m_effectId == 0xA6 -- Magic resistance bonus (166)
				or effect.m_effectId == 0xAD -- Poison resistance bonus (173)
				or effect.m_effectId == 0xBE -- Increase attack speed factor (190)
				or effect.m_effectId == 0xBF -- Casting level bonus (191)
				or effect.m_effectId == 0xC8 -- Spell turning (200)
				or effect.m_effectId == 0xC9 -- Spell deflection (201)
				or effect.m_effectId == 0xD8 -- Level drain (216)
				or effect.m_effectId == 0xDC -- Remove spell school protections (220)
				or effect.m_effectId == 0xDD -- Remove spell type protections (221)
				or effect.m_effectId == 0xDE -- Teleport field (222)
				or effect.m_effectId == 0xDF -- Spell school deflection (223)
				or effect.m_effectId == 0xE2 -- Spell type deflection (226)
				or effect.m_effectId == 0xE3 -- Spell school turning (227)
				or effect.m_effectId == 0xE4 -- Spell type turning (228)
				or effect.m_effectId == 0xE5 -- Remove protection by school (229)
				or effect.m_effectId == 0xE6 -- Remove protection by type (230)
				or effect.m_effectId == 0xEA -- Create contingency (234)
				or effect.m_effectId == 0xEB -- Wing buffet (235)
				or effect.m_effectId == 0xF3 -- Drain item charges (243)
				or effect.m_effectId == 0xF4 -- Drain wizard spells (244)
				or effect.m_effectId == 0xFA -- Maximum damage each hit (250)
				or effect.m_effectId == 0xFF -- Create item (days) (255)
				or effect.m_effectId == 0x101 -- Create spell sequencer (257)
				or effect.m_effectId == 0x103 -- Spell trap (259)
				or effect.m_effectId == 0x106 -- Visual range bonus (262)
				or effect.m_effectId == 0x10D -- Shake screen (269)
				or effect.m_effectId == 0x12D -- Critical hit bonus (301)
				or effect.m_effectId == 0x149 -- Slow poison (329)
				or effect.m_effectId == 0x14C -- Attack damage type bonus (332)
				or effect.m_effectId == 0x16A -- Critical miss bonus (362)
			then
				effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
			end
			--
			if effect.m_effectId == 0x63 then -- Modify duration (99)
				if effect.m_effectAmount ~= 100 then
					if effect.m_effectAmount > 100 then
						effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
					else
						effect.m_effectAmount = effect.m_effectAmount - math.floor(effect.m_effectAmount / 2)
					end
				end
			end
			--
			if effect.m_effectId == 0x7E -- Movement rate bonus (126)
				or effect.m_effectId == 0xB0 -- Movement rate bonus 2 (176)
			then
				if effect.m_dWFlags == 0 then -- mode: increment
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				elseif effect.m_dWFlags == 2 or effect.m_dWFlags == 5 then -- mode: set % / set multiplicative %
					if effect.m_effectAmount ~= 100 then
						if effect.m_effectAmount > 100 then
							effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
						else
							effect.m_effectAmount = effect.m_effectAmount - math.floor(effect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if effect.m_effectId == 0x0 then -- AC bonus
				if EEex_IsBitSet(effect.m_dWFlags, 0x4) then -- mode: set base AC
					if effect.m_effectAmount > 10 then
						effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
					else
						if effect.m_effectAmount >= 0 then
							effect.m_effectAmount = effect.m_effectAmount - math.floor(effect.m_effectAmount / 2)
						else
							effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
						end
					end
				else
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				end
			end
			--
			if effect.m_effectId == 0x21 -- Save vs. death bonus (33)
				or effect.m_effectId == 0x22 -- Save vs. wand bonus (34)
				or effect.m_effectId == 0x23 -- Save vs. polymorph bonus (35)
				or effect.m_effectId == 0x24 -- Save vs. breath bonus (36)
				or effect.m_effectId == 0x25 -- Save vs. spell bonus (37)
				or effect.m_effectId == 0x145 -- All saving throws bonus (325)
			then
				if effect.m_dWFlags == 0 or effect.m_dWFlags == 3 then -- mode: increment / increment instantaneously
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				elseif effect.m_dWFlags == 2 then -- mode: set %
					if effect.m_effectAmount ~= 100 then
						if effect.m_effectAmount > 100 then
							effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
						else
							effect.m_effectAmount = effect.m_effectAmount - math.floor(effect.m_effectAmount / 2)
						end
					end
				end
			end
			--
			if effect.m_effectId == 0xDA then -- Stoneskin (218)
				if effect.m_dWFlags == 1 then -- use dice
					if effect.m_effectAmount > 1 then
						effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
					elseif effect.m_diceSize > 1 then
						effect.m_diceSize = effect.m_diceSize + math.floor(effect.m_diceSize / 2)
					end
				else
					effect.m_effectAmount = effect.m_effectAmount + math.floor(effect.m_effectAmount / 2)
				end
			end
			--
			if effect.m_effectId == 0x14D then -- Static charge (333)
				effect.m_dWFlags = effect.m_dWFlags + math.floor(effect.m_dWFlags / 2) -- increase spell level by 50%
			end
		------------------------------------------------------------------------------
		elseif originatingEffect.m_effectAmount == 3 then -- EXTEND
			if not EEex_Projectile_IsOfType(projectile, EEex_Projectile_Type["CProjectileArea"]) then
				if effect.m_effectId == 0x14D then -- Static charge (333)
					effect.m_effectAmount = effect.m_effectAmount * 2 -- # hits
				else
					if effect.m_durationType == 0 -- limited (seconds)
						or effect.m_durationType == 3 -- delay/limited (seconds)
						or effect.m_durationType == 4 -- delay/permanent (seconds)
						or effect.m_durationType == 10 -- limited (ticks)
					then
						effect.m_duration = effect.m_duration * 2
					end
				end
			end
		---------------------------------------------------------------------------------
		elseif originatingEffect.m_effectAmount == 4 then -- MAXIMIZE
			if effect.m_effectId == 0xC -- Damage
				or effect.m_effectId == 0x11 -- Current HP bonus (17)
				or effect.m_effectId == 0x12 -- Max HP bonus (18)
				or effect.m_effectId == 0x7F -- Summon Monsters (127)
				or effect.m_effectId == 0x14B -- Summon Monsters 2 (331)
			then
				effect.m_effectAmount = effect.m_effectAmount + effect.m_numDice * effect.m_diceSize
				effect.m_diceSize = 0
				effect.m_numDice = 0
			end
			if effect.m_effectId == 0xDA then -- Stoneskin (218)
				if effect.m_dWFlags == 1 then -- mode: use dice values
					effect.m_effectAmount = effect.m_effectAmount + effect.m_numDice * effect.m_diceSize
					effect.m_diceSize = 0
					effect.m_numDice = 0
				end
			end
			if effect.m_effectId == 0x14D then -- Static charge (333)
				effect.m_dWFlags = 0xFFFF -- spell level: max unsigned value (65535)
			end
		end
	end
}
