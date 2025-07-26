EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("tome01")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122014
    IF ~~ THEN GOTO NewItem2
    IF ~PartyHasItem("tome01")
        PartyHasItem("tome02a")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122015
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122016
    IF ~PartyGoldLT(5000)~ THEN REPLY #66956 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66957 DO ~SetGlobal("CDItems","ar0334",6)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("tome01",1)
                                                 DestroyItem("tome01")
                                                 TakePartyItemNum("tome02a",1)
                                                 DestroyItem("tome02a")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66959 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
