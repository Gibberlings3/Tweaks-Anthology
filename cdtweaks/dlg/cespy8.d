// extend cespenar's generic item search with cromwell's items
EXTEND_BOTTOM BOTSMITH 4
  IF ~PartyHasItem("misc5k")~ THEN GOTO mace // illithium ore for MoD+2, needs blun12
END

APPEND BOTSMITH

  IF ~~ THEN BEGIN mace SAY @123002
    IF ~PartyHasItem("blun12")~ THEN GOTO mace_want
    IF ~!PartyHasItem("blun12")~ THEN GOTO need_mace
  END

  IF ~~ THEN BEGIN need_mace SAY @123003
    COPY_TRANS BOTSMITH 4
  END

  IF ~~ THEN BEGIN mace_want SAY @123004
    IF ~PartyGoldLT(7500)~ THEN REPLY #66908 GOTO 10
    IF ~PartyGoldGT(7499)~ THEN REPLY #66909 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",8)
                                                 TakePartyGold(7500)
                                                 TakePartyItemNum("misc5k",1)
                                                 DestroyItem("misc5k")
                                                 TakePartyItemNum("blun12",1)
                                                 DestroyItem("blun12")
                                                 DestroyGold(7500)~ GOTO 11
    IF ~~ THEN REPLY #66910 GOTO mace_stall
  END

  IF ~~ THEN BEGIN mace_stall SAY @123005
    COPY_TRANS BOTSMITH 4
  END

END
