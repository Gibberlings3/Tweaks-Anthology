// extend cespenar's generic item search with cromwell's items
EXTEND_BOTTOM BOTSMITH 4
  IF ~PartyHasItem("hamm07")~ THEN GOTO crom // crom faeyr
END

APPEND BOTSMITH

  IF ~~ THEN BEGIN crom SAY @123024
    IF ~OR(3)
          !PartyHasItem("scrlag")
          !PartyHasItem("brac06")
          !PartyHasItem("belt08")~ THEN GOTO need_crom
    IF ~PartyHasItem("scrlag")
        PartyHasItem("brac06")
        PartyHasItem("belt08")~ THEN GOTO crom_want
  END

  IF ~~ THEN BEGIN need_crom SAY @123025
    COPY_TRANS BOTSMITH 4
  END

  IF ~~ THEN BEGIN crom_want SAY @123026 = @123027
    IF ~PartyGoldLT(10000)~ THEN REPLY #66908 GOTO 10
    IF ~PartyGoldGT(9999)~ THEN REPLY #66909 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",3)
                                                 TakePartyGold(10000)
                                                 TakePartyItemNum("hamm07",1)
                                                 DestroyItem("hamm07")
                                                 TakePartyItemNum("scrlag",1)
                                                 DestroyItem("scrlag")
                                                 TakePartyItemNum("brac06",1)
                                                 DestroyItem("brac06")
                                                 TakePartyItemNum("belt08",1)
                                                 DestroyItem("belt08")
                                                 DestroyGold(10000)~ GOTO 11
    IF ~~ THEN REPLY #66910 GOTO crom_stall
  END

  IF ~~ THEN BEGIN crom_stall SAY @123028
    COPY_TRANS BOTSMITH 4
  END

END
