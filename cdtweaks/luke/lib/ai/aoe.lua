-- checks if the targeted creature is within a cone of width X (in degrees) and radius Y (see f.i. Cone of Cold) --

local function isPtInArc(ptEdgeX, ptEdgeY, nCheckAngle, ptCheckX, ptCheckY)

	--print(string.format("  [isPtInArc] ptEdge: (%d,%d), nCheckAngle: %d, ptCheck: (%d,%d)",
		--ptEdgeX, ptEdgeY, nCheckAngle, ptCheckX, ptCheckY))

	if ptCheckX == 0 and ptCheckY == 0 then
		--print("    result: true")
		return true
	end

	local nDotProduct = ptEdgeX * ptCheckX + ptEdgeY * ptCheckY

	local fEdgeMagnitude = math.sqrt(ptEdgeX * ptEdgeX + ptEdgeY * ptEdgeY)
	local fCheckMagnitude = math.sqrt(ptCheckX * ptCheckX + ptCheckY * ptCheckY)

	local fCosine = nDotProduct / (fEdgeMagnitude * fCheckMagnitude)

	local fClampedCosine = math.max(-1.0, math.min(fCosine, 1.0))
	local fRadians = math.acos(fClampedCosine)
	local nAngle = math.floor((fRadians * 180 / math.pi)) -- truncating to match engine

	local result = nAngle <= nCheckAngle / 2
	--print(string.format("    result: %s", result and "true" or "false"))
	return result
end

local function testCone(angle, ox, oy, tx, ty, px, py)

	if angle <= 180 then
		-- Vector from cone source to target pos
		local nEdgeX = tx - ox
		local nEdgeY = ty - oy
		-- Vector from cone source to potential target object
		local nCheckX = px - ox
		local nCheckY = py - oy

		if isPtInArc(nEdgeX, nEdgeY, angle, nCheckX, nCheckY) then
			return true
		end
	else
		-- Vector from cone source to target pos
		local nEdgeX = ox - tx
		local nEdgeY = oy - ty
		-- Vector from cone source to potential target object
		local nCheckX = px - ox
		local nCheckY = py - oy

		if not isPtInArc(nEdgeX, nEdgeY, 360 - angle, nCheckX, nCheckY) then
			return true
		end
	end

	return false
end

-- AoE radius check (try avoiding friendly fire) --

function GT_AI_AoERadiusCheck(missileType, scriptRunner, targetSprite)

	local toReturn = true

	if scriptRunner == nil then
		scriptRunner = EEex_LuaTrigger_Object -- CGameSprite
	end

	if targetSprite == nil then
		EEex_Error("``targetSprite`` cannot be nil")
	end

	-- BG2:EE -> 250, CONECOLD.PRO
	-- IWD:EE -> 335, IDPRO25.PRO
	-- local proResRef = "IDPRO25"
	local proResRef = GT_Resource_IDSToSymbol["projectl"][missileType - 1]

	if proResRef == nil then
		return true
	end

	local pHeader = EEex_Resource_Demand(proResRef, "pro")

	if pHeader == nil then
		return true
	end

	local m_wFileType = pHeader.m_wFileType

	if m_wFileType == 3 then -- AoE

		local projectile = CProjectile.DecodeProjectile(missileType, scriptRunner)

		if projectile == nil then
			return true
		end

		toReturn = false

		EEex_Utility_TryFinally(function()

			-- NB.: the projectile starts at an offset from the caster!!!
			local projX, projY, projZ = projectile:getStartingPos(scriptRunner, {
				["targetObject"] = targetSprite,
			})

			local m_dwAreaFlags = pHeader.m_dwAreaFlags
			local m_explosionRange = pHeader.m_explosionRange
			local m_bIgnoreLOS = EEex_IsBitSet(m_dwAreaFlags, 12)
			local m_checkForNonSprites = EEex_IsBitSet(m_dwAreaFlags, 1)
			local m_terrainTable = projectile.m_terrainTable
			local m_coneSize = pHeader.m_coneSize

			local tryToHit, tryToAvoid = {}, {}

			local findObjects = function(aiType)
				if EEex_IsBitSet(m_dwAreaFlags, 11) then
					-- cone
					return scriptRunner.m_pArea:getAllOfTypeInRange(projX, projY, aiType, m_explosionRange, not m_bIgnoreLOS, m_checkForNonSprites, m_terrainTable)
				else
					-- circle
					return targetSprite:getAllOfTypeInRange(aiType, m_explosionRange, not m_bIgnoreLOS, m_checkForNonSprites, m_terrainTable)
				end
			end

			if EEex_IsBitUnset(m_dwAreaFlags, 6) and EEex_IsBitUnset(m_dwAreaFlags, 7) then

				-- EA-unfriendly, try avoiding friendly fire (see f.i. Fireball, Arrow of Detonation)
				-- Assuming target EA is what I want to hit with this spell

				if targetSprite.m_typeAI.m_EnemyAlly < 30 then -- [GOODCUTOFF]
					tryToHit = findObjects(GT_AI_ObjectType["GOODCUTOFF"])
					tryToAvoid = findObjects(GT_AI_ObjectType["EVILCUTOFF"])
				elseif targetSprite.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
					tryToHit = findObjects(GT_AI_ObjectType["EVILCUTOFF"])
					tryToAvoid = findObjects(GT_AI_ObjectType["GOODCUTOFF"])
				end

			elseif EEex_IsBitSet(m_dwAreaFlags, 6) then

				-- EA-friendly, see f.i. Bless/Haste/Curse

				if EEex_IsBitSet(m_dwAreaFlags, 7) then
					-- Only allies of caster
					if scriptRunner.m_typeAI.m_EnemyAlly < 30 then -- [GOODCUTOFF]
						tryToHit = findObjects(GT_AI_ObjectType["GOODCUTOFF"])
					elseif scriptRunner.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
						tryToHit = findObjects(GT_AI_ObjectType["EVILCUTOFF"])
					end
				else
					-- Only enemies of caster
					if scriptRunner.m_typeAI.m_EnemyAlly < 30 then -- [GOODCUTOFF]
						tryToHit = findObjects(GT_AI_ObjectType["EVILCUTOFF"])
					elseif scriptRunner.m_typeAI.m_EnemyAlly > 200 then -- [EVILCUTOFF]
						tryToHit = findObjects(GT_AI_ObjectType["GOODCUTOFF"])
					end
				end
			end

			local toHitWithinRange = 0
			local toAvoidWithinRange = 0

			--print("--- Projection")

			--[[
			print(string.format("scriptRunner: %s, targetSprite: %s, scriptRunnerPos: (%d,%d), targetSpritePos: (%d,%d), proj: (%d,%d)",
				scriptRunner:getName(), targetSprite:getName(),
				scriptRunner.m_pos.x, scriptRunner.m_pos.y,
				targetSprite.m_pos.x, targetSprite.m_pos.y,
				projX, projY
			))
			--]]

			--print("trying to hit:")
			for _, itrSprite in ipairs(tryToHit) do
				--print(string.format("  itrSprite: %s (%d,%d)", itrSprite:getName(), itrSprite.m_pos.x, itrSprite.m_pos.y))
				if EEex_IsBitUnset(m_dwAreaFlags, 11) or (
					itrSprite.m_id ~= scriptRunner.m_id
					and testCone(m_coneSize, projX, projY, targetSprite.m_pos.x, targetSprite.m_pos.y, itrSprite.m_pos.x, itrSprite.m_pos.y)
				) then
					--print("    "..itrSprite:getName())
					toHitWithinRange = toHitWithinRange + 1
				end
			end

			--print("trying to avoid:")
			for _, itrSprite in ipairs(tryToAvoid) do
				--print(string.format("  itrSprite: %s (%d,%d)", itrSprite:getName(), itrSprite.m_pos.x, itrSprite.m_pos.y))
				if EEex_IsBitUnset(m_dwAreaFlags, 11) or (
					itrSprite.m_id ~= scriptRunner.m_id
					and testCone(m_coneSize, projX, projY, targetSprite.m_pos.x, targetSprite.m_pos.y, itrSprite.m_pos.x, itrSprite.m_pos.y)
				) then
					--print("    "..itrSprite:getName())
					toAvoidWithinRange = toAvoidWithinRange + 1
				end
			end

			if math.random(0, toHitWithinRange) > toAvoidWithinRange then -- NB.: the source *might* hit a friendly target (provided that: # unfriendly targets > # friendly targets)
				toReturn = true
			end
		end,
		function() projectile:virtual_Destruct(true) end)
	end

	return toReturn
end

-- Check if AoE missile (AoE projectiles only impact through their explosion and/or secondary projectiles) --

function GT_AI_IsAoEMissile(projectileType)
	local flags = 0x0
	local m_secondaryProjectile = -1
	--
	local proResRef = GT_Resource_IDSToSymbol["projectl"][projectileType]
	--
	if proResRef then -- sanity check
		local pHeader = EEex_Resource_Demand(proResRef, "pro")
		--
		if pHeader then -- sanity check
			local m_wFileType = pHeader.m_wFileType
			--
			if m_wFileType == 3 then -- AoE
				flags = 0x4 -- BIT2 (Bypasses deflection/reflection/trap opcodes)
				m_secondaryProjectile = pHeader.m_secondaryProjectile
			end
		end
	end
	--
	return flags, m_secondaryProjectile - 1
end

