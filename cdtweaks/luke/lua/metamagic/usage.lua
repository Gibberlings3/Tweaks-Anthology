-- cdtweaks: NWN-ish metamagic feat for spellcasters (cancel metamagic mode if the caster is not casting a wizard / priest spell || the given spell cannot be modified... Make the spell uninterruptible if quickened) --

EEex_Action_AddSpriteStartedActionListener(function(sprite, action)
	local metamagicType = EEex_Sprite_GetStat(sprite, GT_Resource_SymbolToIDS["stats"]["CDTWEAKS_METAMAGIC"])
	local metamagicArray = {"CDMTMQCK", "CDMTMEMP", "CDMTMEXT", "CDMTMMAX"}
	--
	if sprite:getLocalInt("cdtweaksMetamagic") == 1 then
		if metamagicType > 0 then
			if not (action.m_actionID == 31 or action.m_actionID == 95 or action.m_actionID == 476) then -- Spell() / SpellPoint() / EEex_SpellObjectOffset()
				sprite:applyEffect({
					["effectID"] = 321, -- Remove effects by resource
					["durationType"] = 1,
					["res"] = metamagicArray[metamagicType],
					["sourceID"] = sprite.m_id,
					["sourceTarget"] = sprite.m_id,
				})
			else
				local spellResRef = action.m_string1.m_pchData:get()
				if spellResRef == "" then
					spellResRef = GT_Utility_DecodeSpell(action.m_specificID)
				end
				--
				local spellHeader = EEex_Resource_Demand(spellResRef, "SPL")
				local spellType = spellHeader.itemType
				--
				local casterLevel = EEex_Sprite_GetCasterLevelForSpell(sprite, spellResRef, true)
				local spellAbility = EEex_Resource_GetSpellAbilityForLevel(spellHeader, casterLevel)
				--
				if not (spellType == 1 or spellType == 2) then
					sprite:applyEffect({
						["effectID"] = 321, -- Remove effects by resource
						["durationType"] = 1,
						["res"] = metamagicArray[metamagicType],
						["sourceID"] = sprite.m_id,
						["sourceTarget"] = sprite.m_id,
					})
				else
					local found = false
					--
					if metamagicType == 1 then -- quicken spell
						-- ``ReallyForceSpell()`` ignores range and LoS, so we need to check them...
						if action.m_actionID == 95 or action.m_actionID == 476 then -- SpellPoint() / EEex_SpellObjectOffset()
							local numCreature = EEex_Area_GetAllOfTypeStringInRange(sprite.m_pArea, action.m_dest.x, action.m_dest.y, "[ANYONE]", (spellAbility.range * 16 < sprite:virtual_GetVisualRange()) and spellAbility.range or sprite:virtual_GetVisualRange(), nil, nil, nil)
							for _, v in ipairs(numCreature) do
								if v.m_id == sprite.m_id then
									found = true
									break
								end
							end
						else -- ``Spell()``
							local targetSprite = EEex_GameObject_Get(action.m_acteeID.m_Instance)
							local numCreature = EEex_Area_GetAllOfTypeStringInRange(sprite.m_pArea, targetSprite.m_pos.x, targetSprite.m_pos.y, "[ANYONE]", (spellAbility.range * 16 < sprite:virtual_GetVisualRange()) and spellAbility.range or sprite:virtual_GetVisualRange(), nil, nil, nil)
							for _, v in ipairs(numCreature) do
								if v.m_id == sprite.m_id then
									found = true
									break
								end
							end
						end
					else
						found = true
					end
					--
					if not found then
						action.m_actionID = 0 -- nuke current action (do not "cancel" the metamagic mode: let the caster try again)
						sprite:applyEffect({
							["effectID"] = 139, -- Display string
							["durationType"] = 1,
							["effectAmount"] = %strref_OutOfRange%,
							["sourceID"] = sprite.m_id,
							["sourceTarget"] = sprite.m_id,
						})
					else
						local spellLevelMemListArray
						--
						if spellType == 1 then -- Wizard
							spellLevelMemListArray = sprite.m_memorizedSpellsMage
						elseif spellType == 2 then -- Priest
							spellLevelMemListArray = sprite.m_memorizedSpellsPriest
						end
						--
						local metamagicReq = {4, 2, 1, 3} -- quicken (+4), empower (+2), extend (+1), maximize (+3)
						local spellLevel = spellHeader.spellLevel
						local found = false
						--
						if not (spellType == 1) or (spellLevel + metamagicReq[metamagicType]) <= 9 then -- the "modified" spell must be of level [1-9]
							if not (spellType == 2) or (spellLevel + metamagicReq[metamagicType]) <= 7 then -- the "modified" spell must be of level [1-7]
								--
								local alreadyDecreasedResrefs = {}
								local memList = spellLevelMemListArray:getReference(spellLevel + metamagicReq[metamagicType] - 1) -- count starts from 0 (that is why ``-1``)
								--
								EEex_Utility_IterateCPtrList(memList, function(memInstance)
									local memInstanceResref = memInstance.m_spellId:get()
									if not alreadyDecreasedResrefs[memInstanceResref] then
										local memFlags = memInstance.m_flags
										if EEex_IsBitSet(memFlags, 0x0) then -- if memorized ...
											memInstance.m_flags = EEex_UnsetBit(memFlags, 0x0) -- ... then unmemorize
											found = true
											alreadyDecreasedResrefs[memInstanceResref] = true
										end
									end
								end)
							end
						end
						--
						if not found then
							action.m_actionID = 0 -- nuke current action (do not "cancel" the metamagic mode: let the caster try again)
							sprite:applyEffect({
								["effectID"] = 139, -- Display string
								["durationType"] = 1,
								["effectAmount"] = %strref_CannotBeModified%,
								["sourceID"] = sprite.m_id,
								["sourceTarget"] = sprite.m_id,
							})
						else
							if metamagicType == 1 then -- quicken spell
								-- Morph ``Spell()`` into ``ReallyForceSpell()`` (so as to achieve immuninty to spell disruption)
								local reallyForceSpell = nil
								-- if the aura is not free, delay the action
								if EEex_Sprite_GetCastTimer(sprite) == -1 then -- aura free
									if action.m_actionID == 31 then -- Spell()
										local targetSprite = EEex_GameObject_Get(action.m_acteeID.m_Instance)
										EEex_LuaObject = targetSprite -- must be global
										reallyForceSpell = EEex_Action_ParseResponseString(string.format('ReallyForceSpellRES("%s",EEex_LuaObject)', spellResRef))
									elseif action.m_actionID == 95 or action.m_actionID == 476 then -- SpellPoint() / EEex_SpellObjectOffset()
										reallyForceSpell = EEex_Action_ParseResponseString(string.format('ReallyForceSpellPointRES("%s",[%d.%d])', spellResRef, action.m_dest.x, action.m_dest.y))
									end
								else
									if action.m_actionID == 31 then -- Spell()
										local targetSprite = EEex_GameObject_Get(action.m_acteeID.m_Instance)
										EEex_LuaObject = targetSprite -- must be global
										reallyForceSpell = EEex_Action_ParseResponseString(string.format('SmallWait(%d) \n ReallyForceSpellRES("%s",EEex_LuaObject)', 99 - EEex_Sprite_GetCastTimer(sprite), spellResRef))
									elseif action.m_actionID == 95 or action.m_actionID == 476 then -- SpellPoint() / EEex_SpellObjectOffset()
										reallyForceSpell = EEex_Action_ParseResponseString(string.format('SmallWait(%d) \n ReallyForceSpellPointRES("%s",[%d.%d])', 99 - EEex_Sprite_GetCastTimer(sprite), spellResRef, action.m_dest.x, action.m_dest.y))
									end
								end
								--
								action.m_actionID = 147 -- RemoveSpell()
								--
								reallyForceSpell:queueResponseOnAIBase(sprite)
								reallyForceSpell:free()
								-- ``ReallyForceSpell()`` does not set the aura, so we manually set it...
								sprite.m_castCounter = 0
								sprite.m_bInCasting = 1
							end
						end
					end
				end
			end
		end
	end
end)
