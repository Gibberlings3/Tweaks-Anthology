ADD_TRANS_ACTION ~%tutu_var%KHALID~ BEGIN 0 END BEGIN 0 END ~SetGlobal("P#AlreadyTalkedKhalid","GLOBAL",1)~

APPEND ~%KHALID_BANTER%~

IF WEIGHT #-2 ~
Global("P#KhalidMage","GLOBAL",2)~ THEN BEGIN KHMAGE1
SAY @0
++ @1 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.1
+~!Class(Player1,FIGHTER_MAGE)~+ @2 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.2
+~Class(Player1,FIGHTER_MAGE)~+ @3 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.2M
+~Class(Player1,FIGHTER_ALL) Race(Player1, HUMAN) CheckStatGT(Player1,16,INT)~+ @4 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.2F
++ @5 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.3
+~InParty("jaheira")~+ @6 DO ~SetGlobal("P#KhalidMage","GLOBAL",3)~ + KHMAPC1.4
END
IF ~~ KHMAPC1.1
SAY @7
+ ~!Class(Player1, MAGE_ALL)~+ @8+ KHMAPC1.5
+ ~Class(Player1, MAGE_ALL)~+ @9+ KHMAPC1.5M
++ @10 EXIT
END
IF ~~ KHMAPC1.2
SAY @11
++ @12 + KHMAPC1.6
++ @13 + KHMAPC1.7
++ @14 EXIT
END
IF ~~ KHMAPC1.2M
SAY @15
++ @16 + KHMAPC1.6
++ @13 + KHMAPC1.7
++ @17 EXIT
END
IF ~~ KHMAPC1.2F
SAY @18
++ @16 + KHMAPC1.6
++ @13 + KHMAPC1.7
++ @17 EXIT
END
IF ~~ KHMAPC1.3
SAY @19
+ ~!Class(Player1, MAGE_ALL)~+ @8+ KHMAPC1.5
+ ~Class(Player1, MAGE_ALL)~+ @9+ KHMAPC1.5M
++ @10 EXIT
+~!Class(Player1,FIGHTER_MAGE)~+ @20 + KHMAPC1.2
+~Class(Player1,FIGHTER_MAGE)~+ @3 + KHMAPC1.2M
+~Class(Player1,FIGHTER_ALL) Race(Player1, HUMAN) CheckStatGT(Player1,16,INT)~+ @4 + KHMAPC1.2F
+~Gender(Player1,FEMALE) InParty("jaheira")~+ @21 + KHMAPC1.8F
+~Gender(Player1,MALE) InParty("jaheira")~+ @21 + KHMAPC1.8M
END
IF ~~ KHMAPC1.4
SAY @22
IF ~~ THEN EXIT
END
IF ~~ KHMAPC1.5
SAY @23
++ @24 + KHMAPC1.7
++ @25 EXIT
END
IF ~~ KHMAPC1.5M
SAY @26
++ @24 + KHMAPC1.7
++ @25 EXIT
END
IF ~~ KHMAPC1.6

SAY @27
++ @24 + KHMAPC1.7
++ @25 EXIT
END
IF ~~ KHMAPC1.7
SAY @28
= @29
++ @30 + KHMAPC1.9
++ @31 + KHMAPC1.10
++ @32 + KHMAPC1.11
END
IF ~~ KHMAPC1.8F
SAY @33
IF ~~ THEN EXIT
END
IF ~~ KHMAPC1.8M
SAY @34
IF ~~ THEN EXIT
END
IF ~~ KHMAPC1.9
SAY @35
IF ~~ THEN EXIT
END
IF ~~ KHMAPC1.10
SAY @36
IF ~~ THEN EXIT
END
IF ~~ KHMAPC1.11
SAY @37
++ @38 EXIT
++ @39 + KHMAPC1.12
END
IF ~~ KHMAPC1.12
SAY @40
IF ~~ THEN EXIT
END

END


