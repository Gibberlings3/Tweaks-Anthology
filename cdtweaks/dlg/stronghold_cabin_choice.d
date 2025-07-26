// give players a chance to decline the ranger stronghold
ADD_TRANS_TRIGGER UHMAY01 34 ~False()~ DO 0 // false existing reply-less trigger, other PC replies not shown
EXTEND_BOTTOM UHMAY01 34
  IF ~GlobalLT("Chapter","GLOBAL",%bg2_chapter_6%)~ REPLY @116009 GOTO CDDeclineCabin
  IF ~GlobalLT("Chapter","GLOBAL",%bg2_chapter_6%)~ REPLY @116010 GOTO CDDeclineCabin
  IF ~GlobalGT("Chapter","GLOBAL",%bg2_chapter_5%)~ REPLY @116011 GOTO CDDeclineCabin
  IF ~~                                             REPLY @116012 GOTO 35
  IF ~~                                             REPLY @116013 GOTO 38
END

APPEND UHMAY01

  IF ~~ THEN BEGIN CDDeclineCabin SAY @116014
    IF ~~ THEN GOTO 37
  END

END
