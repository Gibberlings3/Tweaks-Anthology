--[[
+-----------------------------------------------------------------------------------------------------------+
| "Custom" ``EEex_Trigger_ParseConditionalString()`` + ``EEex_Trigger_EvalScriptFileConditionalAsAIBase()`` |
+-----------------------------------------------------------------------------------------------------------+
--]]

local isGeneral = function(sprite, symbol)
	local general = GT_Resource_SymbolToIDS["general"]
	--
	return GT_Sprite_CheckIDS(sprite, general[symbol], 3)
end

local isRace = function(sprite, symbol)
	local race = GT_Resource_SymbolToIDS["race"]
	--
	return GT_Sprite_CheckIDS(sprite, race[symbol], 4)
end

local isClass = function(sprite, symbol)
	local class = GT_Resource_SymbolToIDS["class"]
	--
	return GT_Sprite_CheckIDS(sprite, class[symbol], 5, true)
end

local isKit = function(sprite, symbol)
	return symbol == EEex_Resource_KitIDSToSymbol(sprite:getActiveStats().m_nKit)
end

local isSpellState = function(sprite, symbol)
	local splstate = GT_Resource_SymbolToIDS["splstate"]
	--
	return EEex_Sprite_GetSpellState(sprite, splstate[symbol])
end

----------------------------------------------------------------------------------------------------------------------------------------------------------

GT_EvalConditional = {
	["default"] = function(source, target, flip)
		return flip and false or true
	end,

	["mirrorImage"] = function(source, target, flip)
		local toReturn = EEex_IsBitSet(target:getActiveStats().m_generalState, 30)
		--
		return flip and not toReturn or toReturn
	end,

	["stoneSkins"] = function(source, target, flip)
		local toReturn = target:getActiveStats().m_nStoneSkins > 0
		--
		return flip and not toReturn or toReturn
	end,

	["sneakAttack"] = function(source, target, flip)
		local m_bImmunityToBackStab = target:getActiveStats().m_bImmunityToBackStab > 0
		local isBarbarian = isKit(target, "BARBARIAN")
		--
		local isThief = isClass(source, "THIEF_ALL")
		local isCat = isRace(source, "CAT")
		local isStalker = isClass(source, "RANGER_ALL") and isKit(source, "STALKER")
		--
		local toReturn = (isThief or isCat or isStalker) and (m_bImmunityToBackStab or isBarbarian) or not flip
		--
		return flip and not toReturn or toReturn
	end,

	["resistCold"] = function(source, target, flip)
		local toReturn = target:getActiveStats().m_nResistCold >= math.random(100) -- 1d100
		--
		return flip and not toReturn or toReturn
	end,

	["largeCreature"] = function(source, target, flip)
		local toReturn = EEex_Sprite_GetPersonalSpace(target) > 3 -- PERSONALSPACE>3
		--
		return flip and not toReturn or toReturn
	end,

	["webWalker"] = function(source, target, flip)
		local toReturn = isRace(target, "SPIDER") or isRace(target, "ETTERCAP")
		--
		return flip and not toReturn or toReturn
	end,

	["webbed"] = function(source, target, flip)
		local webWalker = GT_EvalConditional["webWalker"](nil, source, false)
		local toReturn = webWalker and target:getActiveStats().m_bWeb > 0 or not flip
		--
		return flip and not toReturn or toReturn
	end,

	["incorporealCreature"] = function(source, target, flip)
		local toReturn = (isRace(target, "SPECTRE") or isRace(target, "SPECTRAL_UNDEAD") or isRace(target, "SHADOW") or isRace(target, "WRAITH") or isRace(target, "MIST"))
			or (isClass(target, "SPIDER_WRAITH") or isClass(target, "SPECTRAL_TROLL"))
		--
		return flip and not toReturn or toReturn
	end,

	["levitatingCreature"] = function(source, target, flip)
		local toReturn = isGeneral(target, "WEAPON")
			or (isRace(target, "DEMILICH") or isRace(target, "BEHOLDER") or isRace(target, "WILL-O-WISP") or isRace(target, "FEYR"))
		--
		return flip and not toReturn or toReturn
	end,

	["slime"] = function(source, target, flip)
		return flip and not isRace(target, "SLIME") or isRace(target, "SLIME")
	end,

	["elemental"] = function(source, target, flip)
		return flip and not isRace(target, "ELEMENTAL") or isRace(target, "ELEMENTAL")
	end,

	["eyeOfTheSword"] = function(source, target, flip)
		local selectedWeapon = GT_Sprite_GetSelectedWeapon(source)
		local toReturn = selectedWeapon["ability"].damageType ~= 5 and isSpellState(target, "EYE_OF_THE_SWORD") or not flip -- ignore non-lethal damage
		--
		return flip and not toReturn or toReturn
	end,

	["incapacitated"] = function(source, target, flip)
		local toReturn = EEex_BAnd(target:getActiveStats().m_generalState, 0x100029) ~= 0
		--
		return flip and not toReturn or toReturn
	end,

	["parseConditionalString"] = function(source, target, string, scriptingTarget)
		if target then
			source:setStoredScriptingTarget(scriptingTarget, target)
		end
		local conditionalString = EEex_Trigger_ParseConditionalString(string)
		--
		local toReturn = false
		--
		if conditionalString:evalConditionalAsAIBase(source) then
			toReturn = true
		end
		--
		conditionalString:free()
		return toReturn
	end,

}

