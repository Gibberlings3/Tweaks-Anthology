EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("helm29")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122003
    IF ~OR(2)
          !PartyHasItem("ring05")
          !PartyHasItem("potn20")~ THEN GOTO NewItem2
    IF ~PartyHasItem("ring05")
        PartyHasItem("potn20")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122004
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122005
    IF ~PartyGoldLT(10000)~ THEN REPLY #67011 GOTO NoThanks
    IF ~PartyGoldGT(9999)~ THEN REPLY #67012 DO ~SetGlobal("CDItems","ar0334",2)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(10000)
                                                 TakePartyItemNum("helm29",1)
                                                 TakePartyItemNum("ring05",1)
                                                 TakePartyItemNum("potn20",1)
                                                 DestroyItem("potn20")
                                                 DestroyItem("ring05")
                                                 DestroyItem("helm29")
                                                 DestroyGold(10000)~ GOTO 56
    IF ~~ THEN REPLY #67013 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
