EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("quiver02")~ THEN GOTO NewItem
END

APPEND WSMITH01

  IF ~~ THEN BEGIN NewItem SAY @122001
    IF ~PartyGoldLT(5000)~ THEN REPLY #70892 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #70893 DO ~SetGlobal("CDItems","ar0334",1)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("quiver02",1)
                                                 DestroyGold(5000)
                                                 DestroyItem("quiver02")~ GOTO 56
    IF ~~ THEN REPLY #70894 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END

END
