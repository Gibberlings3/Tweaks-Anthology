-- cdtweaks, make grease ignitable: greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

function GTGRSFLM(op403CGameEffect, CGameEffect, CGameSprite)
	local dmgtype = GT_Resource_SymbolToIDS["dmgtype"]
	--
	local roll = Infinity_RandomNumber(1, 3)
	--
	if CGameEffect.m_effectId == 0xC and EEex_IsMaskSet(CGameEffect.m_dWFlags, dmgtype["FIRE"]) then
		local effectCodes = {}
		--
		if roll == 1 then
			effectCodes = {
				{["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100}, -- 3d6 (save vs. breath for half)
			}
		else
			effectCodes = {
				{["op"] = 215, ["res"] = "#SHROUD", ["p2"] = 1, ["dur"] = (6 * roll) - 6}, -- play visual effect (Over target (attached))
				{["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100}, -- 3d6 (save vs. breath for half)
			}
			for i = 2, roll do
				table.insert(effectCodes, {["op"] = 12, ["p2"] = dmgtype["FIRE"], ["dnum"] = 3, ["dsize"] = 6, ["stype"] = 0x2, ["spec"] = 0x100, ["tmg"] = 4, ["dur"] = (6 * roll) - 6}) -- 3d6 (save vs. breath for half)
			end
		end
		--
		for _, attributes in ipairs(effectCodes) do
			CGameSprite:applyEffect({
				["effectID"] = attributes["op"] or -1,
				["dwFlags"] = attributes["p2"] or 0,
				["savingThrow"] = attributes["stype"] or 0,
				["special"] = attributes["spec"] or 0,
				["numDice"] = attributes["dnum"] or 0,
				["diceSize"] = attributes["dsize"] or 0,
				["res"] = attributes["res"] or "",
				["duration"] = attributes["dur"] or 0,
				["durationType"] = attributes["tmg"] or 0,
				["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
				["m_sourceType"] = CGameEffect.m_sourceType,
				["sourceID"] = CGameEffect.m_sourceId,
				["sourceTarget"] = CGameEffect.m_sourceTarget,
			})
		end
	end
end

-- cdtweaks, make grease ignitable: greased targets suffer 3d6 additional fire damage per 1d3 rounds (save vs. breath for half) --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("cdtweaksMakeGreaseIgnitable", 1)
		--
		sprite:applyEffect({
			["effectID"] = 321, -- Remove effects by resource
			["res"] = "CDGRSFLM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
		sprite:applyEffect({
			["effectID"] = 403, -- Screen effects
			["durationType"] = 9,
			["res"] = "GTGRSFLM", -- Lua func
			["m_sourceRes"] = "CDGRSFLM",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
	local spriteGrease = sprite.m_derivedStats.m_bGrease
	--
	local applyCondition = spriteGrease > 0
	--
	if sprite:getLocalInt("cdtweaksMakeGreaseIgnitable") == 0 then
		if applyCondition then
			apply()
		end
	else
		if applyCondition then
			-- do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("cdtweaksMakeGreaseIgnitable", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "CDGRSFLM",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
