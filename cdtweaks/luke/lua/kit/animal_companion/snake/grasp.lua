--[[
+------------------------------------------------------------------------------------+
| Snake Grasp: targeted creature is constricted for 5 rounds (+1 round per 5 levels) |
+------------------------------------------------------------------------------------+
--]]

-- main op402 listener --

function %INNATE_SNAKE_GRASP%(CGameEffect, CGameSprite)
	local sourceSprite = EEex_GameObject_Get(CGameEffect.m_sourceId)
	--local sourceAux = EEex_GetUDAux(sourceSprite)
	--
	if CGameEffect.m_effectAmount == 0 then
		local sourceActiveStats = EEex_Sprite_GetActiveStats(sourceSprite)
		--
		local levelModifier = math.floor(sourceActiveStats.m_nLevel1 / 5) -- +1 round every 5 levels
		--
		local holdImmunity = "EEex_IsImmuneToOpcode(Myself,185)"
		--
		if not GT_EvalConditional["parseConditionalString"](CGameSprite, CGameSprite, holdImmunity) then
			-- store targeted creature (sprite)
			--sourceAux["gt_Aux_SnakeGrasp_CoiledVictim"] = CGameSprite
			-- store targeted creature (id): this is because ``aux`` does not survive reloads, so if we save and reload the game while grasping a creature, the coiled victim will be lost
			sourceSprite:setLocalInt("gtSnakeGraspCoiledVictimID", CGameSprite.m_id)
			-- free the coiled victim upon death
			do
				local effectCodes = {
					--{["op"] = 0xE8, ["p2"] = 16}, -- cast spell on condition (232), cond: Die()
					{["op"] = 0x92, ["p2"] = 1, ["tmg"] = 4}, -- cast spell (146), mode: instant/ignore level (nuke aux upon expiration)
				}
				--
				for _, attributes in ipairs(effectCodes) do
					sourceSprite:applyEffect({
						["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
						["dwFlags"] = attributes["p2"] or 0,
						["res"] = "%INNATE_SNAKE_GRASP%B",
						["durationType"] = attributes["tmg"] or 0,
						["duration"] = (6 * 5) + (6 * levelModifier),
						["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
						["m_sourceType"] = CGameEffect.m_sourceType,
						["sourceID"] = sourceSprite.m_id,
						["sourceTarget"] = sourceSprite.m_id,
					})
				end
			end
			-- actual grasp (not dispellable by Free Action &c.)
			-- nuke aux upon target death
			do
				local effectCodes = {
					--{["op"] = 0xE8, ["p2"] = 16, ["res"] = "%INNATE_SNAKE_GRASP%B", ["spec"] = 0x2}, -- cast spell on condition (232), cond: Die(), spec: Fire subspell as effect source (the creature that casts the spell) instead of effect host (the creature the effect is attached to)
					{["op"] = 0xB9, ["p2"] = 2}, -- hold II (185)
					{["op"] = 0xCE, ["res"] = "%INNATE_SNAKE_GRASP%", ["p1"] = %feedback_strref_already_constricted%}, -- protection from spell (206), string: already constricted
				}
				--
				for _, attributes in ipairs(effectCodes) do
					CGameSprite:applyEffect({
						["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
						["dwFlags"] = attributes["p2"] or 0,
						["effectAmount"] = attributes["p1"] or 0,
						["res"] = attributes["res"] or "",
						["special"] = attributes["spec"] or 0,
						["duration"] = (6 * 5) + (6 * levelModifier),
						["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
						["m_sourceType"] = CGameEffect.m_sourceType,
						["sourceID"] = CGameEffect.m_sourceId,
						["sourceTarget"] = CGameEffect.m_sourceTarget,
					})
				end
			end
		else
			CGameSprite:applyEffect({
				["effectID"] = 324,
				["res"] = CGameEffect.m_sourceRes:get(),
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	else
		local victim = EEex_GameObject_Get(sourceSprite:getLocalInt("gtSnakeGraspCoiledVictimID")) -- CGameSprite
		--
		sourceSprite:applyEffect({
			["effectID"] = 321, -- remove effects by resource
			["res"] = "%INNATE_SNAKE_GRASP%",
			["noSave"] = true,
			["sourceID"] = sourceSprite.m_id,
			["sourceTarget"] = sourceSprite.m_id,
		})
		--
		if victim then
			victim:applyEffect({
				["effectID"] = 321, -- remove effects by resource
				["res"] = "%INNATE_SNAKE_GRASP%",
				["noSave"] = true,
				["sourceID"] = victim.m_id,
				["sourceTarget"] = victim.m_id,
			})
			victim:applyEffect({
				["effectID"] = 139, -- feedback string
				["effectAmount"] = %feedback_strref_break_free%,
				["noSave"] = true,
				["sourceID"] = victim.m_id,
				["sourceTarget"] = victim.m_id,
			})
			--
			sourceSprite:setLocalInt("gtSnakeGraspCoiledVictimID", -1)
		end
	end
end

-- make sure to nuke the aux upon death (we do not trust op232). This is because auxiliary values are not cleared upon death --
-- also, make sure to clear delayed op146 on the snake upon victim's death --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	--local aux = EEex_GetUDAux(sprite)
	local victim = EEex_GameObject_Get(sprite:getLocalInt("gtSnakeGraspCoiledVictimID")) -- CGameSprite
	--
	if victim then
		local found = false
		EEex_Utility_IterateCPtrList(victim.m_timedEffectList, function(effect)
			if effect.m_effectId == 185 and effect.m_sourceId == sprite.m_id and effect.m_sourceRes:get() == "%INNATE_SNAKE_GRASP%" then
				found = true
				return true
			end
		end)
		--
		if not found then
			sprite:applyEffect({
				["effectID"] = 146, -- cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%INNATE_SNAKE_GRASP%B",
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- free the coiled victim upon getting petrified/frozen/stunned/mazed/imprisoned/... --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) or not sprite.m_pArea then
		return
	end
	--
	--local aux = EEex_GetUDAux(sprite)
	local victim = EEex_GameObject_Get(sprite:getLocalInt("gtSnakeGraspCoiledVictimID")) -- CGameSprite
	--
	local isMazed = false
	--
	local func = function(effect)
		if effect.m_effectId == 177 or effect.m_effectId == 283 then -- Use EFF file
			local CGameEffectBase = EEex_Resource_Demand(effect.m_res:get(), "eff")
			--
			if CGameEffectBase then -- sanity check
				if func(CGameEffectBase) then
					isMazed = true
					return true
				end
			end
		elseif effect.m_effectId == 0xD5 then -- Maze (213)
			isMazed = true
			return true
		end
	end
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, func)
	--
	if victim then
		local conditionalString = 'Range(EEex_Target("gtScriptingTarget"),4)'
		--
		if EEex_BAnd(sprite.m_derivedStats.m_generalState, 0x80102FEF) ~= 0 or not EEex_UDEqual(sprite.m_pArea, victim.m_pArea) or isMazed or not GT_EvalConditional["parseConditionalString"](sprite, victim, conditionalString) then
			sprite:applyEffect({
				["effectID"] = 146, -- cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%INNATE_SNAKE_GRASP%B",
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- free the coiled victim upon a successful open doors roll --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	local constricted = false
	local id = -1
	local timerRunning = false
	--
	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)
		if effect.m_effectId == 185 and effect.m_sourceRes:get() == "%INNATE_SNAKE_GRASP%" then
			constricted = true
			id = effect.m_sourceId
		elseif effect.m_effectId == 401 and effect.m_special == stats["GT_DUMMY_STAT"] and effect.m_scriptName:get() == "gtSnakeGraspTimer" then -- dummy opcode that acts as a marker/timer
			timerRunning = true
		end
	end)
	--
	if constricted then
		if EEex_GameObject_Get(id) then -- sanity check
			local src = EEex_GameObject_Get(id) -- CGameSprite (snake)
			--
			if not timerRunning then
				-- fetch components of check
				local strmod = GT_Resource_2DA["strmod"]
				local strmodex = GT_Resource_2DA["strmodex"]
				--
				local strBonus = tonumber(strmod[tostring(sprite.m_derivedStats.m_nSTR)]["BEND_BARS_LIFT_GATES"])
				local strExtraBonus = sprite.m_derivedStats.m_nSTR == 18 and tonumber(strmodex[tostring(sprite.m_derivedStats.m_nSTRExtra)]["BEND_BARS_LIFT_GATES"]) or 0
				--
				local roll = math.random(tonumber(strmod["19"]["BEND_BARS_LIFT_GATES"]))
				--
				if strBonus + strExtraBonus >= roll then
					src:applyEffect({
						["effectID"] = 146, -- cast spell
						["dwFlags"] = 1, -- instant/ignore level
						["res"] = "%INNATE_SNAKE_GRASP%B",
						["noSave"] = true,
						["sourceID"] = src.m_id,
						["sourceTarget"] = src.m_id,
					})
				else
					-- set timer (+1d6 crushing damage)
					sprite:applyEffect({
						["effectID"] = 401, -- Set extended stat
						["special"] = stats["GT_DUMMY_STAT"],
						["m_scriptName"] = "gtSnakeGraspTimer",
						["duration"] = 6,
						["noSave"] = true,
						["m_sourceRes"] = "%INNATE_SNAKE_GRASP%",
						["sourceID"] = src.m_id,
						["sourceTarget"] = sprite.m_id,
					})
					sprite:applyEffect({
						["effectID"] = 12, -- Damage
						["numDice"] = 1,
						["diceSize"] = 6,
						["sourceID"] = src.m_id,
						["sourceTarget"] = sprite.m_id,
					})
				end
			end
		else
			sprite:applyEffect({
				["effectID"] = 146, -- cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%INNATE_SNAKE_GRASP%B",
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- free the coiled victim upon attacking/casting/moving/... --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	--local aux = EEex_GetUDAux(sprite)
	local victim = EEex_GameObject_Get(sprite:getLocalInt("gtSnakeGraspCoiledVictimID")) -- CGameSprite
	--
	local actionSources = {
		[31] = true, -- Spell()
		[95] = true, -- SpellPoint()
		[191] = true, -- SpellNoDec()
		[192] = true, -- SpellPointNoDec()
		[113] = true, -- ForceSpell()
		[114] = true, -- ForceSpellPoint()
		[181] = true, -- ReallyForceSpell()
		[318] = true, -- ForceSpellRange()
		[319] = true, -- ForceSpellPointRange()
		[337] = true, -- ReallyForceSpellPoint()
		[476] = true, -- EEex_SpellObjectOffset()
		[477] = true, -- EEex_SpellObjectOffsetNoDec()
		[478] = true, -- EEex_ForceSpellObjectOffset()
		[479] = true, -- EEex_ReallyForceSpellObjectOffset()
		--
		[3] = true, -- Attack()
		[94] = true, -- GroupAttack()
		[98] = true, -- AttackNoSound()
		[105] = true, -- AttackOneRound()
		[134] = true, -- AttackReevaluate()
	}
	--
	if victim then
		if actionSources[action.m_actionID] then
			sprite:applyEffect({
				["effectID"] = 146, -- cast spell
				["dwFlags"] = 1, -- instant/ignore level
				["res"] = "%INNATE_SNAKE_GRASP%B",
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		else
			sprite:applyEffect({
				["effectID"] = 0x16E, -- Apply spell on movement
				["res"] = "%INNATE_SNAKE_GRASP%B",
				["duration"] = 1,
				["noSave"] = true,
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Anyone who attempts to free a captive by hacking at the constrictor has a 20% chance of striking the victim instead --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	--
	local attackerAux = EEex_GetUDAux(sprite)
	--
	local actionSources = {
		[3] = true, -- Attack()
		[94] = true, -- GroupAttack()
		[98] = true, -- AttackNoSound()
		[105] = true, -- AttackOneRound()
		[134] = true, -- AttackReevaluate()
	}
	--
	local m_curAction = sprite.m_curAction -- CAIAction
	--
	if sprite.m_startedSwing == 1 then
		if actionSources[m_curAction.m_actionID] and not attackerAux["gt_SnakeGrasp_StrikeVictim"] then
			attackerAux["gt_SnakeGrasp_StrikeVictim"] = {}
			--
			local target = EEex_GameObject_Get(sprite.m_targetId) -- CGameSprite
			-- if the targeted creature is not dead...
			if target and EEex_IsBitUnset(target.m_derivedStats.m_generalState, 11) then
				--local targetAux = EEex_GetUDAux(target)
				local victim = EEex_GameObject_Get(target:getLocalInt("gtSnakeGraspCoiledVictimID")) -- CGameSprite
				--
				local roll = math.random(20) -- 1d20
				--
				local conditionalString = 'InWeaponRange(EEex_Target("gtScriptingTarget"))'
				--
				if victim and roll <= 4 and GT_EvalConditional["parseConditionalString"](sprite, victim, conditionalString) then -- 20% chance + InWeaponRange()
					-- store original ``m_actionID`` and ``m_acteeID``
					-- NB.: this is because we recall some weirdness with ``AttackReevaluate()`` and how it stores its target!
					attackerAux["gt_SnakeGrasp_StrikeVictim"] = {
						["actionID"] = m_curAction.m_actionID,
						["instance"] = m_curAction.m_acteeID.m_Instance,
					}
					--
					m_curAction.m_actionID = 105 -- ``AttackOneRound()``
					m_curAction.m_acteeID.m_Instance = victim.m_id
				end
			end
		end
	elseif attackerAux["gt_SnakeGrasp_StrikeVictim"] then
		-- restore original action if needed
		if actionSources[m_curAction.m_actionID] and attackerAux["gt_SnakeGrasp_StrikeVictim"]["actionID"] then
			m_curAction.m_actionID = attackerAux["gt_SnakeGrasp_StrikeVictim"]["actionID"]
		end
		if actionSources[m_curAction.m_actionID] and attackerAux["gt_SnakeGrasp_StrikeVictim"]["instance"] then
			m_curAction.m_acteeID.m_Instance = attackerAux["gt_SnakeGrasp_StrikeVictim"]["instance"]
		end
		--
		attackerAux["gt_SnakeGrasp_StrikeVictim"] = nil
	end
end)

