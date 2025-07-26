EXTEND_BOTTOM multig 1

  IF ~Global("AR2000_visited","GLOBAL",0)
      Global("Chapter","GLOBAL",0)
      !AreaCheck("AR1006")
      OR(3) // make sure we're not in how/totl
        !GlobalGT("Hjollder_Quest","GLOBAL",2)
        Global("HOW_COMPLETED","GLOBAL",1)
        Global("Exp_Pause","GLOBAL",1)~ THEN REPLY @107004 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO cradle // prologue, go to Winter's Cradle Tavern
  IF ~Global("AR2100_visited","GLOBAL",1)
      GlobalGT("Chapter","GLOBAL",0)
      Global("AR1100_visited","GLOBAL",0)
      !AreaCheck("AR2111")
      OR(3) // make sure we're not in how/totl
        !GlobalGT("Hjollder_Quest","GLOBAL",2)
        Global("HOW_COMPLETED","GLOBAL",1)
        Global("Exp_Pause","GLOBAL",1)~ THEN REPLY @107005 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO root // anywhere but eh finale, go to Root Cellar Tavern
  IF ~GlobalGT("Hjollder_Quest","GLOBAL",2)
      !Global("HOW_COMPLETED","GLOBAL",1)
      !Global("Exp_Pause","GLOBAL",1)
      !AreaCheck("AR9101") // whistling gallows
      !AreaCheck("AR9300") // burial isle
      !AreaCheck("AR9301") // edions tower
      !AreaCheck("AR9400") // wylfdene's barrow
      !AreaCheck("AR9600") // sea of moving ice
      !AreaCheck("AR9601") // sea of moving ice - cave entrance
      !AreaCheck("AR9602") // sea of moving ice - field of bones
      !AreaCheck("AR9603") // sea of moving ice - icasaracht exterior
      !AreaCheck("AR9604") // sea of moving ice - icasaracht interior
      OR(2) // make sure we're not in totl
        Global("Master_Quest","GLOBAL",0)
        GlobalGT("Master_Quest","GLOBAL",6)~ THEN REPLY @107006 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO gallows // go to Whistling Gallows

END

APPEND ~multig~
  IF ~~ THEN BEGIN cradle SAY @107009
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_cradle","GLOBAL",1) EscapeAreaMove("AR1006",472,489,9)~ EXIT
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_cradle","GLOBAL",1) EscapeAreaMove("AR1006",532,486,6)~ EXIT
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_cradle","GLOBAL",1) EscapeAreaMove("AR1006",538,428,3)~ EXIT
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_cradle","GLOBAL",1) EscapeAreaMove("AR1006",502,402,0)~ EXIT
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_cradle","GLOBAL",1) EscapeAreaMove("AR1006",459,408,13)~ EXIT
    IF ~Global("CDMultiNPCNo_cradle","GLOBAL",5)~ THEN DO ~SetGlobal("CDMultiNPCNo_cradle","GLOBAL",1)       EscapeAreaMove("AR1006",440,464,10)~ EXIT
  END

  IF ~~ THEN BEGIN root SAY @107009
    IF ~Global("CDMultiNPCNo_root","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_root","GLOBAL",1) EscapeAreaMove("AR2111",350,306,15)~ EXIT
    IF ~Global("CDMultiNPCNo_root","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_root","GLOBAL",1) EscapeAreaMove("AR2111",325,352,12)~ EXIT
    IF ~Global("CDMultiNPCNo_root","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_root","GLOBAL",1) EscapeAreaMove("AR2111",355,425,8)~ EXIT
    IF ~Global("CDMultiNPCNo_root","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_root","GLOBAL",1) EscapeAreaMove("AR2111",151,258,4)~ EXIT
    IF ~Global("CDMultiNPCNo_root","GLOBAL",4)~ THEN DO ~SetGlobal("CDMultiNPCNo_root","GLOBAL",0)       EscapeAreaMove("AR2111",53,232,14)~ EXIT
  END

  IF ~~ THEN BEGIN gallows SAY @107009
    IF ~Global("CDMultiNPCNo_gallows","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_gallows","GLOBAL",1) EscapeAreaMove("AR9101",885,585,6)~ EXIT
    IF ~Global("CDMultiNPCNo_gallows","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_gallows","GLOBAL",1) EscapeAreaMove("AR9101",705,448,9)~ EXIT
    IF ~Global("CDMultiNPCNo_gallows","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_gallows","GLOBAL",1) EscapeAreaMove("AR9101",784,398,8)~ EXIT
    IF ~Global("CDMultiNPCNo_gallows","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_gallows","GLOBAL",1) EscapeAreaMove("AR9101",835,378,6)~ EXIT
    IF ~Global("CDMultiNPCNo_gallows","GLOBAL",4)~ THEN DO ~SetGlobal("CDMultiNPCNo_gallows","GLOBAL",0)       EscapeAreaMove("AR9101",872,332,4)~ EXIT
  END

END
