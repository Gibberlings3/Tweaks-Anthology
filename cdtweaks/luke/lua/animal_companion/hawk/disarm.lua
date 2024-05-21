-- cdtweaks, Animal Companion (hawk): disarm the tageted creature

function GTACP08A(CGameEffect, CGameSprite)
	local items = CGameSprite.m_equipment.m_items -- Array<CItem*,39>
	local stats = GT_Resource_SymbolToIDS["stats"]
	local found = false
	--
	for i = 35, 38 do -- WEAPON[1-4]
		local item = items:get(i) -- CItem
		if item then
			-- check if not NONDROPABLE
			if not EEex_IsBitSet(item.m_flags, 0x3) then
				local resref = item.pRes.resref:get()
				local header = item.pRes.pHeader -- Item_Header_st
				local animationType = EEex_CastUD(header.animationType, "CResRef"):get()
				-- check if DROPPABLE
				if EEex_IsBitSet(header.itemFlags, 0x2) then
					-- check if weapon animation
					if animationType == "AX" -- Battle Axe
						or animationType == "BS" -- Shortbow
						or animationType == "BW" -- Longbow
						or animationType == "CB" -- Crossbow
						or animationType == "CL" -- Club
						or animationType == "DD" -- Dagger
						or animationType == "F0" -- Flail (alternate 1)
						or animationType == "F1" -- Flail (alternate 2)
						or animationType == "F3" -- Flail (alternate 3)
						or animationType == "FL" -- Flail
						or animationType == "HB" -- Halberd
						or animationType == "M2" -- Mace (alternate)
						or animationType == "MC" -- Mace
						or animationType == "MS" -- Morning star
						or animationType == "Q2" -- Quarterstaff (alternate 1)
						or animationType == "Q3" -- Quarterstaff (alternate 2)
						or animationType == "Q4" -- Quarterstaff (alternate 3)
						or animationType == "QS" -- Quarterstaff
						or animationType == "S0" -- Bastard sword
						or animationType == "S1" -- Long sword
						or animationType == "S2" -- Two-handed sword
						or animationType == "S3" -- Katana
						or animationType == "SC" -- Scimitar
						or animationType == "SL" -- Sling
						or animationType == "SP" -- Spear
						or animationType == "SS" -- Short sword
						or animationType == "WH" -- War hammer
					then
						found = true
						--
						EEex_GameObject_ApplyEffect(CGameSprite,
						{
							["effectID"] = 401, -- Set extended stat
							["special"] = stats["GT_DISARM"]
							["effectAmount"] = 1,
							["dwFlags"] = 1, -- mode: set
							["durationType"] = 1,
							["res"] = resref,
							["m_effectAmount2"] = i,
							["m_sourceRes"] = "GTDISARM",
							["sourceID"] = CGameEffect.m_sourceId,
							["sourceTarget"] = CGameEffect.m_sourceTarget,
						})
						--
						local unequip = EEex_Action_ParseResponseString(string.format('XEquipItem("",Myself,%d,EQUIP)', i))
						unequip:executeResponseAsAIBaseInstantly(CGameSprite)
						unequip:free()
					end
				end
			end
		end
	end
	--
	if found then
		for category = 15, 30 do
			if not (category == 28) then -- skip FIST
				EEex_GameObject_ApplyEffect(CGameSprite,
				{
					["effectID"] = 181, -- Disallow item type
					["effectAmount"] = category,
					["duration"] = 6,
					["m_sourceRes"] = CGameEffect.m_sourceRes:get(),
					["m_sourceType"] = CGameEffect.m_sourceType,
					["sourceID"] = CGameEffect.m_sourceId,
					["sourceTarget"] = CGameEffect.m_sourceTarget,
				})
			end
		end
	end
end

-- cdtweaks, Animal Companion (hawk): restore the disarmed weapon(s)

function GTACP08B(CGameEffect, CGameSprite)
	local restore = {}
	local stats = GT_Resource_SymbolToIDS["stats"]
	--
	EEex_Utility_IterateCPtrList(CGameSprite.m_timedEffectList, function(fx)
		if fx.m_effectId == 401 and fx.m_special == stats["GT_DISARM"] and fx.m_dWFlags == 1 and fx.m_effectAmount == 1 and fx.m_sourceRes:get() == "GTDISARM" then
			restore[fx.m_effectAmount2] = fx.m_res:get()
		end
	end)
	--
	EEex_GameObject_ApplyEffect(CGameSprite,
	{
		["effectID"] = 321, -- Remove effects by resource
		["durationType"] = 1,
		["res"] = "GTDISARM",
		["sourceID"] = CGameEffect.m_sourceId,
		["sourceTarget"] = CGameEffect.m_sourceTarget,
	})
	--
	for k, v in pairs(restore) do
		local equip = EEex_Action_ParseResponseString(string.format('XEquipItem("%s",Myself,%d,EQUIP)', v, k))
		equip:executeResponseAsAIBaseInstantly(CGameSprite)
		equip:free()
	end
	-- terminate the op402 effect
	CGameEffect.m_done = true
end
