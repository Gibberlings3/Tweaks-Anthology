EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("compon18")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY #59709 = @122020
    IF ~PartyGoldLT(5000)~ THEN REPLY #66908 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66909  DO ~SetGlobal("CDItems","ar0334",8)
                                                  SetGlobal("ForgeStuff","GLOBAL",1)
                                                  TakePartyGold(5000)
                                                  TakePartyItemNum("compon18",1)
                                                  DestroyItem("compon18")
                                                  DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66910 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
