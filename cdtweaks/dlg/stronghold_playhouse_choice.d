// if no restrictions variant installed, the class check will always be true and the player will always go to the new choice states.
// if class restrictions are in place, we need to retain these class checks, though players will get a chance to decline the stronghold.
ALTER_TRANS RAELIS BEGIN 71 END BEGIN 0 END BEGIN EPILOGUE ~GOTO CDRewardChoiceRaelis~ END // redirect acceptance option to new choice state
ALTER_TRANS HAERDA BEGIN 99 END BEGIN 0 END BEGIN EPILOGUE ~EXTERN RAELIS CDRewardChoiceRaelis2~ END // redirect acceptance option to new choice state

APPEND RAELIS

  IF ~~ THEN BEGIN CDRewardChoiceRaelis SAY @116002
    IF ~~ REPLY @116003 GOTO CDJack
    IF ~~ REPLY @116004 GOTO CDJack
    IF ~~ REPLY @116005 GOTO 22
  END

  IF ~~ THEN BEGIN CDRewardChoiceRaelis2 SAY @116006 = @116007
    IF ~~ REPLY @116003 GOTO 21
    IF ~~ REPLY @116004 GOTO 21
    IF ~~ REPLY @116005 GOTO 20
  END

  IF ~~ THEN BEGIN CDJack SAY @116008
    COPY_TRANS RAELIS 23
  END

END
