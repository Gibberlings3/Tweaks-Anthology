EXTEND_BOTTOM multig 1

  IF ~GlobalLT("Chapter","GLOBAL",%bg2_chapter_8%)
      !AreaCheck("AR0406")~ THEN REPLY #49701 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO copper // Copper Coronet
  IF ~!GlobalLT("Chapter","GLOBAL",%bg2_chapter_8%)
      !AreaCheck("AR4500")
      !AreaCheck("AR4000")
      !AreaCheck("AR6200")~ THEN REPLY @107003 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO pocket // pocket plane

END

APPEND ~multig~

  IF ~~ THEN BEGIN copper SAY @107009
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",689,1127,2)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",916,1201,0)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",807,1523,12)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",1286,1866,8)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",1594,1720,3)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",5)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",270,1287,15)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",6)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",517,1507,7)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",7)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_copper","GLOBAL",1) EscapeAreaMove("AR0406",1435,1976,6)~ EXIT
    IF ~Global("CDMultiNPCNo_copper","GLOBAL",8)~ THEN DO ~SetGlobal("CDMultiNPCNo_copper","GLOBAL",0)       EscapeAreaMove("AR0406",1532,1909,6)~ EXIT
  END

  IF ~~ THEN BEGIN pocket SAY @107009
    IF ~Global("CDMultiNPCNo_pocket","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_pocket","GLOBAL",1) CreateVisualEffectObject("SPDIMNDR",Myself) Wait(2) MoveBetweenAreas("AR4500",[2552.1445],3)~ EXIT
    IF ~Global("CDMultiNPCNo_pocket","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_pocket","GLOBAL",1) CreateVisualEffectObject("SPDIMNDR",Myself) Wait(2) MoveBetweenAreas("AR4500",[2472.1288],2)~ EXIT
    IF ~Global("CDMultiNPCNo_pocket","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_pocket","GLOBAL",1) CreateVisualEffectObject("SPDIMNDR",Myself) Wait(2) MoveBetweenAreas("AR4500",[2574.1500],4)~ EXIT
    IF ~Global("CDMultiNPCNo_pocket","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_pocket","GLOBAL",1) CreateVisualEffectObject("SPDIMNDR",Myself) Wait(2) MoveBetweenAreas("AR4500",[2507.1610],5)~ EXIT
    IF ~Global("CDMultiNPCNo_pocket","GLOBAL",4)~ THEN DO ~SetGlobal("CDMultiNPCNo_pocket","GLOBAL",0)       CreateVisualEffectObject("SPDIMNDR",Myself) Wait(2) MoveBetweenAreas("AR4500",[2364.1663],7)~ EXIT
  END

END
