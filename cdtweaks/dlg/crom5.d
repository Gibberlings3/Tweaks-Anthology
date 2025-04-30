EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("brac22")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122012
    IF ~~ THEN GOTO NewItem2
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122013
    IF ~PartyGoldLT(10000)~ THEN REPLY #66983 GOTO NoThanks
    IF ~PartyGoldGT(9999)~ THEN REPLY #66984 DO ~SetGlobal("CDItems","ar0334",5)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(10000)
                                                 TakePartyItemNum("brac22",1)
                                                 DestroyItem("brac22")
                                                 DestroyGold(10000)~ GOTO 56
    IF ~~ THEN REPLY #66985 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
