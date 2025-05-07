// extend cespenar's generic item search with cromwell's items
EXTEND_BOTTOM BOTSMITH 4
  IF ~PartyHasItem("misc12")~ THEN GOTO ankheg // ankheg shell
END

APPEND BOTSMITH

  IF ~~ THEN BEGIN ankheg SAY @123029
    IF ~PartyGoldLT(5000)~ THEN REPLY #66908 GOTO 10
    IF ~PartyGoldGT(4999)~ THEN REPLY #66909 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",2)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("misc12",1)
                                                 DestroyItem("misc12")
                                                 DestroyGold(5000)~ GOTO 11
    IF ~~ THEN REPLY #66910 GOTO ankheg_stall
  END

  IF ~~ THEN BEGIN ankheg_stall SAY @123030
    COPY_TRANS BOTSMITH 4
  END

END

