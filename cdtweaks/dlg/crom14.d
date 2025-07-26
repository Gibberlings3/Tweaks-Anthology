EXTEND_BOTTOM WSMITH01 13
  IF ~OR(2)
        PartyHasItem("dagg23")
        PartyHasItem("sper11")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122034
    IF ~OR(2)
          !PartyHasItem("dagg23")
          !PartyHasItem("sper11")~ THEN GOTO NewItem2
    IF ~PartyHasItem("dagg23")
        PartyHasItem("sper11")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122035
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122036
    IF ~PartyGoldLT(5000)~ THEN REPLY #66662 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66664 DO ~SetGlobal("CDItems","ar0334",14)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("dagg23",1)
                                                 DestroyItem("dagg23")
                                                 TakePartyItemNum("sper11",1)
                                                 DestroyItem("sper11")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66770 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
