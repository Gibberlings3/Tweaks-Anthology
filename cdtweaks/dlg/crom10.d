EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("slng08")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122024
  IF ~PartyGoldLT(5000)~ THEN REPLY #66872 GOTO NoThanks
  IF ~PartyGoldGT(4999)~ THEN REPLY #66873 DO ~SetGlobal("CDItems","ar0334",10)
                                               SetGlobal("ForgeStuff","GLOBAL",1)
                                               TakePartyGold(5000)
                                               TakePartyItemNum("slng08",1)
                                               DestroyItem("slng08")
                                               DestroyGold(5000)~ GOTO 56
  IF ~~ THEN REPLY #66874 GOTO NoThanks

  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
