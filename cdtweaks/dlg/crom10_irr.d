EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("slng08")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122046 // This is a gnomish sling. I've got a few tricks up my sleeve that can make it more accurate.
    IF ~!PartyHasItem("ring20")~ THEN GOTO NewItem2
    IF ~PartyHasItem("ring20")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122047 // If ye come across a Ring of Energy, I can get ye fixed right up.
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122048 // Give me yon Ring of Energy and 5,000 gold and we can get started.
  IF ~PartyGoldLT(5000)~ THEN REPLY #66872 GOTO NoThanks
  IF ~PartyGoldGT(4999)~ THEN REPLY #66873 DO ~SetGlobal("CDItems","ar0334",10)
                                               SetGlobal("ForgeStuff","GLOBAL",1)
                                               TakePartyGold(5000)
                                               TakePartyItemNum("ring20",1)
                                               DestroyItem("ring20")
                                               TakePartyItemNum("slng08",1)
                                               DestroyItem("slng08")
                                               DestroyGold(5000)~ GOTO 56
  IF ~~ THEN REPLY #66874 GOTO NoThanks

  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
