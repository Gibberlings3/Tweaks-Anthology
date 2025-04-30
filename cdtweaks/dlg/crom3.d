EXTEND_BOTTOM WSMITH01 13
  IF ~OR(3)
        PartyHasItem("helm31")
        PartyHasItem("compon12")
        PartyHasItem("compon13")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122006
    IF ~OR(3)
          !PartyHasItem("helm31")
          !PartyHasItem("compon12")
          !PartyHasItem("compon13")~ THEN GOTO NewItem2
    IF ~PartyHasItem("helm31")
        PartyHasItem("compon12")
        PartyHasItem("compon13")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122007
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122008
    IF ~PartyGoldLT(5000)~ THEN REPLY #67003 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #67004 DO ~SetGlobal("CDItems","ar0334",3)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("helm31",1)
                                                 DestroyItem("helm31")
                                                 TakePartyItemNum("compon12",1)
                                                 DestroyItem("compon12")
                                                 TakePartyItemNum("compon13",1)
                                                 DestroyItem("compon13")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #67005 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
