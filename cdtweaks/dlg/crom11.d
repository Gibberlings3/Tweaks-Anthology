EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("quiver01")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122025
    IF ~!PartyHasItem("misc45")~ THEN GOTO NewItem2
    IF ~PartyHasItem("misc45")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122026
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122027
    IF ~PartyGoldLT(10000)~ THEN REPLY #66800 GOTO NoThanks
    IF ~PartyGoldGT(9999)~ THEN REPLY #66801 DO ~SetGlobal("CDItems","ar0334",11)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(10000)
                                                 TakePartyItemNum("quiver01",1)
                                                 DestroyItem("quiver01")
                                                 TakePartyItemNum("misc45",1)
                                                 DestroyItem("misc45")
                                                 DestroyGold(10000)~ GOTO 56
    IF ~~ THEN REPLY #66802 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
