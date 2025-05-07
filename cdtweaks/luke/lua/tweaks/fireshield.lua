--[[
+-------------------------------------------------------------------------------------------+
| cdtweaks, More Sensible Fireshield                                                        |
+-------------------------------------------------------------------------------------------+
| Fixes two things:                                                                         |
| 1. Fireshield-like spells will no longer bounce back and forth ad infinitum               |
| 2. Only true melee attacks will trigger these spells (no longer ranged attacks or poison) |
+-------------------------------------------------------------------------------------------+
--]]

EEex_Sprite_AddBlockWeaponHitListener(function(args)
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local weapon = args.weapon -- CItem
	local weaponAbility = args.weaponAbility -- Item_ability_st
	local targetSprite = args.targetSprite -- CGameSprite
	local attackingSprite = args.attackingSprite -- CGameSprite
	-- check for Fireshield-like spells
	local effectList = {targetSprite.m_equipedEffectList, targetSprite.m_timedEffectList} -- CGameEffectList
	local retaliation = {}
	--
	for _, list in ipairs(effectList) do
		EEex_Utility_IterateCPtrList(list, function(effect)
			if effect.m_effectId == 401 and effect.m_dWFlags == 1 and effect.m_effectAmount == 1 and effect.m_special == stats["GT_FAKE_CONTINGENCY"] then
				table.insert(retaliation, effect.m_res:get())
			end
		end)
	end
	--
	if weaponAbility.type == 1 and weaponAbility.range <= 2 then -- melee weapons only
		-- apply retaliation damage
		for _, res in ipairs(retaliation) do
			attackingSprite:applyEffect({
				["effectID"] = 146, -- Cast spl
				["dwFlags"] = 1, -- mode: cast instantly / ignore level
				["res"] = res,
				["sourceID"] = targetSprite.m_id,
				["sourceTarget"] = attackingSprite.m_id,
			})
		end
	end
end)
