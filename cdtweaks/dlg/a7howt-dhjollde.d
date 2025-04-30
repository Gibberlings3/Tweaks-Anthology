APPEND ~DHJOLLDE~

// Triggered in Lonelywood if you already visited Hjollder before in Kuldahar without accepting the quest
IF WEIGHT #0 ~NumberOfTimesTalkedTo(0) GlobalGT("Know_Hjollder","GLOBAL",0) GlobalLT("Hjollder_Quest","GLOBAL",3)~ DHJOLLDE.Intro
  SAY #22682 /* ~You have returned. Again it is as the vision foretold.~ [HJOLL026] */
  + ~Global("Hjollder_Quest","GLOBAL",0)~ + #22683 /* ~What is this vision you keep harping on about?~ */ + 2
  + ~!Global("Hjollder_Quest","GLOBAL",0)~ + #22684 /* ~What is it with you and this vision? What do you want from us?~ */ + 7
END

END
