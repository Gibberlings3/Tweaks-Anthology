EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("blun14")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122028
  IF ~!PartyHasItem("blun30a")~ THEN GOTO NewItem2
  IF ~PartyHasItem("blun30a")~ THEN GOTO NewItem3
END

IF ~~ THEN BEGIN NewItem2 SAY @122029
  IF ~~ THEN GOTO NoThanks
END

IF ~~ THEN BEGIN NewItem3 SAY @122030
  IF ~PartyGoldLT(5000)~ THEN REPLY #66768 GOTO NoThanks
  IF ~PartyGoldGT(4999)~ THEN REPLY #66769 DO ~SetGlobal("CDItems","ar0334",12)
                                               SetGlobal("ForgeStuff","GLOBAL",1)
                                               TakePartyGold(5000)
                                               TakePartyItemNum("blun14",1)
                                               DestroyItem("blun14")
                                               TakePartyItemNum("blun30a",1)
                                               DestroyItem("blun30a")
                                               DestroyGold(5000)~ GOTO 56
  IF ~~ THEN REPLY #66770 GOTO NoThanks
END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
