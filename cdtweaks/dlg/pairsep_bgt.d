// bgt khalid uses Dead checks where all other post- dialogues use InParty
REPLACE_TRIGGER_TEXT ~%KHALID_POST%~
  ~!Dead("Jaheira")\([ %TAB%%LNL%%MNL%%WNL%]*Global("IWasKickedOut","LOCALS",0)\)~
  ~InParty("Jaheira") \1~
REPLACE_TRIGGER_TEXT ~%KHALID_POST%~
  ~Dead("Jaheira")\([ %TAB%%LNL%%MNL%%WNL%]*Global("IWasKickedOut","LOCALS",0)\)~
  ~!InParty("Jaheira") \1~
REPLACE_TRIGGER_TEXT ~%KHALID_POST%~
  ~\(Global("IWasKickedOut","LOCALS",0)[ %TAB%%LNL%%MNL%%WNL%]*GlobalLT("ENDOFBG1","GLOBAL",2)[ %TAB%%LNL%%MNL%%WNL%]*\)!Dead("Jaheira")~
  ~\1 InParty("Jaheira")~
REPLACE_TRIGGER_TEXT ~%KHALID_POST%~
  ~\(Global("IWasKickedOut","LOCALS",0)[ %TAB%%LNL%%MNL%%WNL%]*GlobalLT("ENDOFBG1","GLOBAL",2)[ %TAB%%LNL%%MNL%%WNL%]*\)Dead("Jaheira")~
  ~\1 !InParty("Jaheira")~
