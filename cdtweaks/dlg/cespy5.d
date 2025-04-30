// extend cespenar's generic item search with cromwell's items
EXTEND_BOTTOM BOTSMITH 4
  IF ~PartyHasItem("bow19a")~ THEN GOTO gesen // gesen bow
END

APPEND BOTSMITH

  IF ~~ THEN BEGIN gesen SAY @123016
    IF ~!PartyHasItem("bow19b")~ THEN GOTO need_gesen
    IF ~PartyHasItem("bow19b")~ THEN GOTO gesen_want
  END

  IF ~~ THEN BEGIN need_gesen SAY @123017
    COPY_TRANS BOTSMITH 4
  END

  IF ~~ THEN BEGIN gesen_want SAY @123018
    IF ~PartyGoldLT(7500)~ THEN REPLY #66908 GOTO 10
    IF ~PartyGoldGT(7499)~ THEN REPLY #66909 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",5)
                                                 TakePartyGold(7500)
                                                 TakePartyItemNum("bow19a",1)
                                                 DestroyItem("bow19a")
                                                 TakePartyItemNum("bow19b",1)
                                                 DestroyItem("bow19b")
                                                 DestroyGold(7500)~ GOTO 11
    IF ~~ THEN REPLY #66910 GOTO gesen_stall
  END

  IF ~~ THEN BEGIN gesen_stall SAY @123019
    COPY_TRANS BOTSMITH 4
  END

END
