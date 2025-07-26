APPEND ~%tutu_var%ALORA~

// IF WEIGHT #-2 ~NumTimesTalkedTo(0) AreaCheck("%Gullykin%")~ THEN BEGIN AlJoin
IF WEIGHT #-2 ~!StateCheck(Myself,STATE_CHARMED) NumTimesTalkedTo(0) %alora_area_check%~ THEN BEGIN AlJoin
SAY @125017
++ @125016 DO ~SetGlobal("P#TalkedToAlora","GLOBAL",1)~ + ALJONE1.1
++ @125002 DO ~SetGlobal("P#TalkedToAlora","GLOBAL",1)~ + ALJONE1.2
++ @125003 DO ~SetGlobal("P#TalkedToAlora","GLOBAL",1)~ + ALJONE1.3
++ @125004 DO ~SetGlobal("P#TalkedToAlora","GLOBAL",1)~ + ALJONE1.4
END

IF ~~ ALJONE1.1
SAY @125005
  IF ~~ THEN REPLY @125006 + ALJONE1.5
  IF ~~ THEN REPLY @125007 + ALJONE1.6
  IF ~~ THEN REPLY @125008 + ALJONE1.2
END

IF ~~ THEN BEGIN ALJONE1.2
  SAY @125009
  IF ~~ THEN DO ~EscapeArea() DestroySelf()~ EXIT
END

IF ~~ ALJONE1.3
  SAY @125010
  IF ~~ THEN REPLY @125006 + ALJONE1.5
  IF ~~ THEN REPLY @125007 + ALJONE1.6
  IF ~~ THEN REPLY @125008 + ALJONE1.2
END

IF ~~ ALJONE1.4
  SAY @125011
IF ~~ THEN REPLY @125006 + ALJONE1.5
  IF ~~ THEN REPLY @125007 + ALJONE1.6
  IF ~~ THEN REPLY @125008 + ALJONE1.2
END

IF ~~ THEN BEGIN ALJONE1.5
  SAY @125012
  IF ~~ THEN DO ~SetGlobal("P#TalkedToAlora","GLOBAL",2) SetGlobal("KickedOut","LOCALS",0) JoinParty()~ EXIT
END

IF ~~ THEN BEGIN ALJONE1.6
  SAY @125013
  IF ~~ THEN EXIT
END

IF ~~ THEN BEGIN ALJONE1.7
  SAY @125014
  IF ~~ THEN EXIT
END

// IF WEIGHT #-1 ~NumTimesTalkedToGT(0) AreaCheck("%Gullykin%")~ THEN BEGIN AlJoin1
IF WEIGHT #-1 ~!StateCheck(Myself,STATE_CHARMED) NumTimesTalkedToGT(0) %alora_area_check%~ THEN BEGIN AlJoin1
SAY @125015
  IF ~~ THEN REPLY @125006 + ALJONE1.5
  IF ~~ THEN REPLY @125007 + ALJONE1.7
  IF ~~ THEN REPLY @125008 + ALJONE1.2
END
END