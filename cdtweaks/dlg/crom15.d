EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("dagg21")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122037
    IF ~NumItemsPartyLT("misc41",5)~ THEN GOTO NewItem2
    IF ~NumItemsPartyGT("misc41",4)~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122038
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122039
    IF ~PartyGoldLT(5000)~ THEN REPLY #66648 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66649 DO ~SetGlobal("CDItems","ar0334",15)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("dagg21",1)
                                                 DestroyItem("dagg21")
                                                 TakePartyItemNum("misc41",5)
                                                 DestroyItem("misc41")
                                                 DestroyItem("misc41")
                                                 DestroyItem("misc41")
                                                 DestroyItem("misc41")
                                                 DestroyItem("misc41")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66770 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
