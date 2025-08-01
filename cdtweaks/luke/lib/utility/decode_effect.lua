-- Construct ``CGameEffect`` (mainly for use with ``CProjectile:AddEffect()``) --

function GT_Utility_DecodeEffect(args)

	local effect

	EEex_RunWithStackManager({
		{ ["name"] = "itemEffect", ["struct"] = "Item_effect_st" },
		{ ["name"] = "source",     ["struct"] = "CPoint"         },
		{ ["name"] = "target",     ["struct"] = "CPoint"         }, },
		function(manager)

			itemEffect = manager:getUD("itemEffect")
			EEex_WriteUDArgs(itemEffect, args, {
				{ "effectID",         EEex_WriteFailType.ERROR        },
				{ "targetType",       EEex_WriteFailType.DEFAULT, 2   },
				{ "spellLevel",       EEex_WriteFailType.DEFAULT, 0   },
				{ "effectAmount",     EEex_WriteFailType.DEFAULT, 0   },
				{ "dwFlags",          EEex_WriteFailType.DEFAULT, 0   },
				{ "durationType",     EEex_WriteFailType.DEFAULT, 0   },
				{ "duration",         EEex_WriteFailType.DEFAULT, 0   },
				{ "probabilityUpper", EEex_WriteFailType.DEFAULT, 100 },
				{ "probabilityLower", EEex_WriteFailType.DEFAULT, 0   },
				{ "res",              EEex_WriteFailType.DEFAULT, ""  },
				{ "numDice",          EEex_WriteFailType.DEFAULT, 0   },
				{ "diceSize",         EEex_WriteFailType.DEFAULT, 0   },
				{ "savingThrow",      EEex_WriteFailType.DEFAULT, 0   },
				{ "saveMod",          EEex_WriteFailType.DEFAULT, 0   },
				{ "special",          EEex_WriteFailType.DEFAULT, 0   },
			})

			local source = manager:getUD("source")
			source.x = args["sourceX"] or -1
			source.y = args["sourceY"] or -1

			local target = manager:getUD("target")
			target.x = args["targetX"] or -1
			target.y = args["targetY"] or -1

			effect = CGameEffect.DecodeEffect(itemEffect, source, args["sourceID"] or -1, target, args["sourceTarget"] or -1)
		end)

	EEex_WriteUDArgs(effect, args, {
		{ "m_school",          EEex_WriteFailType.NOTHING },
		{ "m_minLevel",        EEex_WriteFailType.NOTHING },
		{ "m_maxLevel",        EEex_WriteFailType.NOTHING },
		{ "m_flags",           EEex_WriteFailType.NOTHING },
		{ "m_effectAmount2",   EEex_WriteFailType.NOTHING },
		{ "m_effectAmount3",   EEex_WriteFailType.NOTHING },
		{ "m_effectAmount4",   EEex_WriteFailType.NOTHING },
		{ "m_effectAmount5",   EEex_WriteFailType.NOTHING },
		{ "m_res2",            EEex_WriteFailType.NOTHING },
		{ "m_res3",            EEex_WriteFailType.NOTHING },
		{ "m_sourceType",      EEex_WriteFailType.NOTHING },
		{ "m_sourceRes",       EEex_WriteFailType.NOTHING },
		{ "m_sourceFlags",     EEex_WriteFailType.NOTHING },
		{ "m_projectileType",  EEex_WriteFailType.NOTHING },
		{ "m_slotNum",         EEex_WriteFailType.NOTHING },
		{ "m_scriptName",      EEex_WriteFailType.NOTHING },
		{ "m_casterLevel",     EEex_WriteFailType.NOTHING },
		{ "m_secondaryType",   EEex_WriteFailType.NOTHING },
	})

	return effect

end

