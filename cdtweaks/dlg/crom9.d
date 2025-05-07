EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("chan16")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122021
    IF ~!PartyHasItem("scrl6t")~ THEN GOTO NewItem2
    IF ~PartyHasItem("scrl6t")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122022
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122023
    IF ~PartyGoldLT(40000)~ THEN REPLY #66900 GOTO NoThanks
    IF ~PartyGoldGT(39999)~ THEN REPLY #66901 DO ~SetGlobal("CDItems","ar0334",9)
                                                  SetGlobal("ForgeStuff","GLOBAL",1)
                                                  TakePartyGold(40000)
                                                  TakePartyItemNum("chan16",1)
                                                  DestroyItem("chan16")
                                                  TakePartyItemNum("scrl6t",1)
                                                  DestroyItem("scrl6t")
                                                  DestroyGold(40000)~ GOTO 56
    IF ~~ THEN REPLY #66902 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
