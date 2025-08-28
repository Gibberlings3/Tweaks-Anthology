-- For use with ``EEex_LuaTrigger()`` and ``EEex_LuaDecode()``

GT_AI_LuaChunks = {
	-- spells
	["%INNATE_WINTER_WOLF_FROST_BREATH%"] = {
		['resref'] = '%INNATE_WINTER_WOLF_FROST_BREATH%',
		['opcode'] = {12},
		['targetIDS'] = {'0'},
		['extra'] = {
			{['resistCold'] = {true, true}},
		},
	},

	["%INNATE_SNAKE_CHARM%"] = {
		['resref'] = '%INNATE_SNAKE_CHARM%',
		['opcode'] = {5},
		['targetIDS'] = {'ANIMAL'},
		['extra'] = {
			{['default'] = {false, false}},
		},
	},

	["%INNATE_SNAKE_GRASP%"] = {
		['resref'] = '%INNATE_SNAKE_GRASP%',
		['opcode'] = {185},
		['targetIDS'] = {'HUMANOID', 'ANIMAL'},
		['extra'] = {
			{
				['largeCreature'] = {true, true},
				['incorporealCreature'] = {true, true},
				['slime'] = {true, true},
				['levitatingCreature'] = {true, true},
				['elemental'] = {true, true},
			},
		},
	},

	["%INNATE_SPIDER_WEB_TANGLE%"] = {
		['resref'] = '%INNATE_SPIDER_WEB_TANGLE%',
		['opcode'] = {157},
		['targetIDS'] = {'0'},
		['extra'] = {
			{
				['incapacitated'] = {false, true},
				['largeCreature'] = {false, true},
				['incorporealCreature'] = {false, true},
				['slime'] = {false, true},
				['levitatingCreature'] = {false, true},
				['elemental'] = {false, true},
			},
		},
	},

	-- weapon attacks
	["default"] = {
		['targetIDS'] = {'0'},
		['extra'] = {
			{['mirrorImage'] = {true, true}, ['stoneSkins'] = {true, true}, ['eyeOfTheSword'] = {true, true}, ["sneakAttack"] = {true, true}},
			{['mirrorImage'] = {true, true}, ['stoneSkins'] = {true, true}, ["sneakAttack"] = {true, true}},
			{['mirrorImage'] = {true, true}, ["sneakAttack"] = {true, true}},
			{["sneakAttack"] = {true, true}},
			{['default'] = {false, false}},
		},
		['opcode'] = {-1},
	},
	["webbedPreferringWeak"] = {
		['targetIDS'] = {'0.0.MAGE', '0.0.MAGE_THIEF', '0.0.MAGE_ALL', '0.0.THIEF', '0.0.BARD_ALL', '0.0.THIEF_ALL', '0.0.SHAMAN', '0.0.DRUID', '0.0.CLERIC', '0'},
		['extra'] = {
			{['mirrorImage'] = {true, true}, ['stoneSkins'] = {true, true}, ['eyeOfTheSword'] = {true, true}, ["webbed"] = {false, false}},
			{['mirrorImage'] = {true, true}, ['stoneSkins'] = {true, true}, ["webbed"] = {false, false}},
			{['mirrorImage'] = {true, true}, ["webbed"] = {false, false}},
			{["webbed"] = {false, false}},
			{['default'] = {false, false}},
		},
		['opcode'] = {-1},
	},
}

