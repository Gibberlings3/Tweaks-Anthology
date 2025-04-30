EXTEND_BOTTOM WSMITH01 13
  IF ~OR(3) PartyHasItem("clck02") PartyHasItem("cdpp9") PartyHasItem("c!pp9")~ THEN GOTO NewItem
END

APPEND WSMITH01
  IF ~~ THEN BEGIN NewItem SAY @122017
    IF ~OR(2)
          !PartyHasItem("scrl90")
          !PartyHasItem("scrl7q")~ THEN GOTO NewItem2
    IF ~PartyHasItem("scrl90")
        PartyHasItem("scrl7q")~ THEN GOTO NewItem3
  END

  IF ~~ THEN BEGIN NewItem2 SAY @122018
    IF ~~ THEN GOTO NoThanks
  END

  IF ~~ THEN BEGIN NewItem3 SAY @122019
    IF ~PartyGoldLT(20000)~ THEN REPLY #66938 GOTO NoThanks
    IF ~PartyGoldGT(19999)
        PartyHasItem("clck02")
        !PartyHasItem("cdpp9")
        !PartyHasItem("c!pp9")~ THEN REPLY #66939 DO ~SetGlobal("CDItems","ar0334",7)
                                                      SetGlobal("ForgeStuff","GLOBAL",1)
                                                      TakePartyGold(20000)
                                                      TakePartyItemNum("clck02",1)
                                                      DestroyItem("clck02")
                                                      TakePartyItemNum("scrl90",1)
                                                      DestroyItem("scrl90")
                                                      TakePartyItemNum("scrl7q",1)
                                                      DestroyItem("scrl7q")
                                                      DestroyGold(20000)~ GOTO 56
    IF ~PartyGoldGT(19999)
        PartyHasItem("cdpp9")
        !PartyHasItem("c!pp9")~ THEN REPLY #66939 DO ~SetGlobal("CDItems","ar0334",7)
                                                      SetGlobal("ForgeStuff","GLOBAL",1)
                                                      TakePartyGold(20000)
                                                      TakePartyItemNum("cdpp9",1)
                                                      DestroyItem("cdpp9")
                                                      TakePartyItemNum("scrl90",1)
                                                      DestroyItem("scrl90")
                                                      TakePartyItemNum("scrl7q",1)
                                                      DestroyItem("scrl7q")
                                                      DestroyGold(20000)~ GOTO 56
    IF ~PartyGoldGT(19999)
        PartyHasItem("c!pp9")~ THEN REPLY #66939 DO ~SetGlobal("CDItems","ar0334",7)
                                                      SetGlobal("ForgeStuff","GLOBAL",1)
                                                      TakePartyGold(20000)
                                                      TakePartyItemNum("c!pp9",1)
                                                      DestroyItem("c!pp9")
                                                      TakePartyItemNum("scrl90",1)
                                                      DestroyItem("scrl90")
                                                      TakePartyItemNum("scrl7q",1)
                                                      DestroyItem("scrl7q")
                                                      DestroyGold(20000)~ GOTO 56
    IF ~~ THEN REPLY #66940 GOTO NoThanks
  END

  IF ~~ THEN BEGIN NoThanks SAY @122002
   COPY_TRANS WSMITH01 13
  END
END
