--[[
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| cdtweaks: hide op215 and hardcoded animations played by opcodes 153, 155, 156, 201, 204, 205, 223, 226, 259, 197, 198, 200, 202, 203, 207, 227, 228, 299 from invisible enemies |
+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
--]]

function GTHIDEAN(op403CGameEffect, CGameEffect, CGameSprite)
	local spriteActiveStats = EEex_Sprite_GetActiveStats(CGameSprite)
	--
	local hideVFX = function(effect)
		if effect.m_effectId == 0xD7 then -- Play visual effect (215)
			effect.m_res2:set(effect.m_res:get()) -- store it for later restoration
			effect.m_res:set("") -- blank VFX
		elseif (effect.m_effectId == 0x99 -- Sanctuary (153)
			or effect.m_effectId == 0x9B -- Minor globe overlay (155)
			or effect.m_effectId == 0x9C) -- Protection from normal missiles overlay (156)
		then
			effect.m_effectAmount = effect.m_dWFlags -- store it for later restoration
			effect.m_res2:set(effect.m_res:get()) -- store it for later restoration
			effect.m_res:set("") -- blank VFX
			effect.m_dWFlags = 1 -- mode: custom
		end
	end
	-- if invisible, hide incoming VFX
	if EEex_IsBitSet(spriteActiveStats.m_generalState, 0x4) then
		if CGameEffect.m_effectId == 0xD7 then -- Play visual effect (215)
			CGameSprite:setLocalInt("gtHideVFXIfInvisible", 1)
			--
			CGameEffect.m_res2:set(CGameEffect.m_res:get()) -- store it for later restoration
			CGameEffect.m_res:set("") -- blank VFX
		elseif (CGameEffect.m_effectId == 0x99 -- Sanctuary (153)
			or CGameEffect.m_effectId == 0x9B -- Minor globe overlay (155)
			or CGameEffect.m_effectId == 0x9C) -- Protection from normal missiles overlay (156)
		then
			CGameSprite:setLocalInt("gtHideVFXIfInvisible", 1)
			--
			CGameEffect.m_effectAmount = CGameEffect.m_dWFlags -- store it for later restoration
			CGameEffect.m_res2:set(CGameEffect.m_res:get()) -- store it for later restoration
			CGameEffect.m_res:set("") -- blank VFX
			CGameEffect.m_dWFlags = 1 -- mode: custom
		end
	else
		-- if about to turn invisible, hide existing VFX
		if CGameEffect.m_effectId == 0x14 and CGameEffect.m_dWFlags == 0 then -- Invisibility (20)
			CGameSprite:setLocalInt("gtHideVFXIfInvisible", 1)
			--
			EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, hideVFX)
			EEex_Utility_IterateCPtrList(CGameSprite.m_equipedEffectList, hideVFX)
			-- suppress hardcoded animations
			EEex_GameObject_ApplyEffect(CGameSprite,
			{
				["effectID"] = 0x123, -- Disable visual effects (291)
				["dwFlags"] = 1,
				["durationType"] = CGameEffect.m_durationType,
				["duration"] = CGameEffect.m_duration,
				["m_sourceRes"] = "GTRMV291",
				["sourceID"] = CGameSprite.m_id,
				["sourceTarget"] = CGameSprite.m_id,
			})
		end
	end
end

-- restore VFX if no longer invisible --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local restoreVFX = function(effect)
		if effect.m_effectId == 0xD7 then -- Play visual effect (215)
			effect.m_res:set(effect.m_res2:get())
			effect.m_res2:set("")
		elseif (effect.m_effectId == 0x99 -- Sanctuary (153)
			or effect.m_effectId == 0x9B -- Minor globe overlay (155)
			or effect.m_effectId == 0x9C) -- Protection from normal missiles overlay (156)
		then
			effect.m_dWFlags = effect.m_effectAmount
			effect.m_res:set(effect.m_res2:get())
			effect.m_res2:set("")
			effect.m_effectAmount = 0
		end
	end
	-- Check creature's state
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGeneralState = sprite.m_derivedStats.m_generalState
	--
	if sprite:getLocalInt("gtHideVFXIfInvisible") == 1 and EEex_IsBitUnset(spriteGeneralState, 0x4) then
		sprite:setLocalInt("gtHideVFXIfInvisible", 0)
		-- remove op291
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTRMV291",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		--
		EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, restoreVFX)
		EEex_Utility_IterateCPtrList(sprite.m_equipedEffectList, restoreVFX)
	end
end)

--

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual condition
	local apply = function()
		-- Mark the creature as 'condition applied'
		sprite:setLocalInt("cdtweaksHideAnimations", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "GTHIDEAN",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTHIDEAN", -- lua function
			["m_sourceRes"] = "GTHIDEAN",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's EA
	local applyCondition = sprite.m_typeAI.m_EnemyAlly > 200 -- EVILCUTOFF
	--
	if sprite:getLocalInt("cdtweaksHideAnimations") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'condition removed'
			sprite:setLocalInt("cdtweaksHideAnimations", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "GTHIDEAN",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
