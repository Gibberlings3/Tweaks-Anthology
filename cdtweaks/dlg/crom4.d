EXTEND_BOTTOM WSMITH01 13
  IF ~PartyHasItem("brac24")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122009
    IF ~OR(4)
         !PartyHasItem("misc43")
         !PartyHasItem("misc42")
         !PartyHasItem("misc41")
         !PartyHasItem("misc45")~ THEN GOTO NewItem2
    IF ~PartyHasItem("misc43")
        PartyHasItem("misc42")
        PartyHasItem("misc41")
        PartyHasItem("misc45")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122010
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122011
    IF ~PartyGoldLT(5000)~ THEN REPLY #66990 GOTO NoThanks
    IF ~PartyGoldGT(4999)~ THEN REPLY #66991 DO ~SetGlobal("CDItems","ar0334",4)
                                                 SetGlobal("ForgeStuff","GLOBAL",1)
                                                 TakePartyGold(5000)
                                                 TakePartyItemNum("brac24",1)
                                                 DestroyItem("brac24")
                                                 TakePartyItemNum("misc41",1)
                                                 DestroyItem("misc41")
                                                 TakePartyItemNum("misc42",1)
                                                 DestroyItem("misc42")
                                                 TakePartyItemNum("misc43",1)
                                                 DestroyItem("misc43")
                                                 TakePartyItemNum("misc45",1)
                                                 DestroyItem("misc45")
                                                 DestroyGold(5000)~ GOTO 56
    IF ~~ THEN REPLY #66992 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
