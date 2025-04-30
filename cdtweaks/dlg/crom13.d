EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("blun26")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122031
    IF ~!PartyHasItem("ring02")~ THEN GOTO NewItem2
    IF ~PartyHasItem("ring02")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122032
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122033
    IF ~PartyGoldLT(5000)~ THEN REPLY #66752 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66753 DO ~SetGlobal("CDItems","ar0334",13)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("blun26",1)
                                                 DestroyItem("blun26")
                                                 TakePartyItemNum("ring02",1)
                                                 DestroyItem("ring02")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66770 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
