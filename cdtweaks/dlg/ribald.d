// change all special stock calls to regular store
REPLACE_ACTION_TEXT ribald ~StartStore("ribald3"~ ~StartStore("ribald"~  

ADD_TRANS_TRIGGER ribald 0 ~OR(2) Global("CDRibaldStore","GLOBAL",100)~ DO 1 // sneaky or(2)!
ADD_TRANS_TRIGGER ribald 0 ~Global("CDRibaldStore","GLOBAL",0)~ DO 2

ALTER_TRANS ribald BEGIN 47 END BEGIN 0 END BEGIN EPILOGUE ~GOTO CDRibaldStore~ END // don't go to 48 without cutscene
ADD_STATE_TRIGGER ribald 48 ~Global("CDRibaldStore","GLOBAL",99)~
ADD_TRANS_ACTION ribald BEGIN 48 END BEGIN END ~SetGlobal("CDRibaldStore","GLOBAL",100)~
SET_WEIGHT ribald 48 #-1

APPEND ribald

  IF ~~ THEN BEGIN CDRibaldStore SAY @351001
    IF ~~                              THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",7)~ EXIT
    IF ~InPartySlot(LastTalkedToBy,1)~ THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",8)~ EXIT
    IF ~InPartySlot(LastTalkedToBy,2)~ THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",9)~ EXIT
    IF ~InPartySlot(LastTalkedToBy,3)~ THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",10)~ EXIT
    IF ~InPartySlot(LastTalkedToBy,4)~ THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",11)~ EXIT
    IF ~InPartySlot(LastTalkedToBy,5)~ THEN DO ~SetGlobal("CDRibaldStore","GLOBAL",12)~ EXIT
  END   

END
