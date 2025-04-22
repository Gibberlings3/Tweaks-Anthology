REPLACE_TRIGGER_TEXT ~garren~   ~Class(Player1,PALADIN\(_[A-Z]+\)?)~ ~True()~
REPLACE_TRIGGER_TEXT ~garren~   ~Kit(Player1,Blackguard)~ ~False()~ // bg2ee

REPLACE_TRIGGER_TEXT ~hprelate~ ~Class(Player1,PALADIN\(_[A-Z]+\)?)~ ~True()~
REPLACE_TRIGGER_TEXT ~hprelate~ ~Kit(Player1,Blackguard)~ ~False()~ // bg2ee

ADD_TRANS_ACTION demson 
BEGIN 119 END
BEGIN END
~EraseJournalEntry(22917)~
