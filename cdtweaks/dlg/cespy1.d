// change existing dragon scale check to include red and shadow dragon scales
ALTER_TRANS BOTSMITH BEGIN 4 END BEGIN 11 END BEGIN TRIGGER ~OR(4)
                                                               PartyHasItem("compon18")
                                                               PartyHasItem("compon19")
                                                               PartyHasItem("scaleb")
                                                               PartyHasItem("scaler")~
                                                    EPILOGUE ~GOTO dragon~ END

// extend generic dragon scale find to include red dragon scales
APPEND BOTSMITH

  IF ~~ THEN BEGIN dragon SAY #66903
    IF ~PartyHasItem("compon18")~ THEN GOTO white
    IF ~PartyHasItem("compon19")~ THEN GOTO blue
    IF ~PartyHasItem("scaleb")~ THEN GOTO shadow
    IF ~PartyHasItem("scaler")~ THEN GOTO red
  END

  IF ~~ THEN BEGIN red SAY @123001
    IF ~~ THEN GOTO choose
    IF ~PartyHasItem("compon18")~ THEN GOTO white
    IF ~PartyHasItem("compon19")~ THEN GOTO blue
    IF ~PartyHasItem("scaleb")~ THEN GOTO shadow
  END

  IF ~~ THEN BEGIN shadow SAY @123031
    IF ~~ THEN GOTO choose
    IF ~PartyHasItem("compon18")~ THEN GOTO white
    IF ~PartyHasItem("compon19")~ THEN GOTO blue
  END

  IF ~~ THEN BEGIN blue SAY @123032
    IF ~~ THEN GOTO choose
    IF ~PartyHasItem("compon18")~ THEN GOTO white
  END

  IF ~~ THEN BEGIN white SAY @123033
    IF ~~ THEN GOTO choose
  END


  IF ~~ THEN BEGIN choose SAY @123034
    IF ~PartyGoldLT(5000)~ THEN REPLY #66908 GOTO 10
    IF ~PartyGoldGT(4999)
        PartyHasItem("compon18")~ THEN REPLY #66915 DO ~SetGlobal("ItemMaker","GLOBAL",26) // white
                                                         TakePartyGold(5000)
                                                         TakePartyItemNum("compon18",1)
                                                         DestroyItem("compon18")
                                                         DestroyGold(5000)~ GOTO 11
    IF ~PartyGoldGT(4999)
        PartyHasItem("compon19")~ THEN REPLY #66916 DO ~SetGlobal("ItemMaker","GLOBAL",27) // blue
                                                         TakePartyGold(5000)
                                                         TakePartyItemNum("compon19",1)
                                                         DestroyItem("compon18")
                                                         DestroyGold(5000)~ GOTO 11
    IF ~PartyGoldGT(4999)
        PartyHasItem("scaleb")~ THEN REPLY @123035 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",9) // shadow
                                                       TakePartyGold(5000)
                                                       TakePartyItemNum("scaleb",1)
                                                       DestroyItem("scaleb")
                                                       DestroyGold(5000)~ GOTO 11
    IF ~PartyGoldGT(4999)
        PartyHasItem("scaler")~ THEN REPLY @123036 DO ~SetGlobal("CDItemMakerTweaks","GLOBAL",1) // red
                                                       TakePartyGold(5000)
                                                       TakePartyItemNum("scaler",1)
                                                       DestroyItem("scaler")
                                                       DestroyGold(5000)~ GOTO 11
    IF ~~ THEN REPLY #66910 GOTO 105
  END

END
