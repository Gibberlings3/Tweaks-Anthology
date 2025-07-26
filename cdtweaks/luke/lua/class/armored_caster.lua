--[[
+-------------------------------------------------------+
| cdtweaks, NWN-ish Armored Caster class feat for Bards |
+-------------------------------------------------------+
--]]

-- Apply ability --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- Sanity check
	if not EEex_GameObject_IsSprite(sprite) then
		return
	end
	-- internal function that applies the actual feat
	local apply = function()
		-- Mark the creature as 'feat applied'
		sprite:setLocalInt("gtNWNArmoredCaster", 1)
		--
		local effectCodes = {
			{["op"] = 321}, -- Remove effects by resource
			{["op"] = 403}, -- EEex: Screen Effects
		}
		--
		for _, attributes in ipairs(effectCodes) do
			sprite:applyEffect({
				["effectID"] = attributes["op"] or EEex_Error("opcode number not specified"),
				["durationType"] = 9,
				["res"] = "%BARD_ARMORED_CASTER%",
				["m_sourceRes"] = "%BARD_ARMORED_CASTER%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
	-- Check creature's class / level / dexterity
	local spriteClassStr = GT_Resource_IDSToSymbol["class"][sprite.m_typeAI.m_Class]
	-- CLASS=BARD
	local applyAbility = spriteClassStr == "BARD"
	--
	if sprite:getLocalInt("gtNWNArmoredCaster") == 0 then
		if applyAbility then
			apply()
		end
	else
		if applyAbility then
			-- Do nothing
		else
			-- Mark the creature as 'feat removed'
			sprite:setLocalInt("gtNWNArmoredCaster", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["res"] = "%BARD_ARMORED_CASTER%",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)

-- Core listener --

function %BARD_ARMORED_CASTER%(op403CGameEffect, CGameEffect, CGameSprite)
	-- if the bard is wielding a light armor, block op145*p2=0
	if CGameEffect.m_effectId == 145 and CGameEffect.m_dWFlags == 0 and CGameEffect.m_slotNum == 1 and CGameEffect.m_sourceType == 2 then
		local pHeader = EEex_Resource_Demand(CGameEffect.m_sourceRes:get(), "itm") -- Item_Header_st
		--
		if pHeader then
			local armorTypeStr = EEex_Resource_ItemCategoryIDSToSymbol(pHeader.itemType)
			local armorAnimation = EEex_CastUD(pHeader.animationType, "CResRef"):get()
			--
			if armorTypeStr == "ARMOR" and armorAnimation == "2A" then
				return true
			end
		end
	end
end
