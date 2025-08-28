// baeloth needs custom code since he's being sent to inn-adjacent areas

// first, turn baeloth's existing departure to a simple 'stay here'; move already handled above
ALTER_TRANS baelothp BEGIN 3 END BEGIN 0 END BEGIN ~REPLY~ ~@20850~ END 
REPLACE_ACTION_TEXT ~baelothp~ ~EscapeAreaMove("%FriendlyArmInn%",[0-9]+,[0-9]+,[0-9NSEW]+)~ ~~

// more or less copied from depart.d, but using custom replies since he's not quite going to the same places
EXTEND_BOTTOM baelothp 0
IF ~Global("BD0120_START","GLOBAL",0)
    Global("EnteredArmInn","GLOBAL",1)
    Global("cd_no_travel_fai_all","GLOBAL",0)
    Global("cd_no_travel_fai_baeloth","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1) // not on Werewolf Isle
    !Global("teth","GLOBAL",1) // not trapped under Candlekeep AR2613, 2615, 2619, 5506
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("%FriendlyArmInn%")~                  // not in the area where the NPC will be sent
THEN REPLY #%baelothreply% GOTO dmww_fai

IF ~Global("BD0120_START","GLOBAL",0)
    Global("EnteredBeregost","GLOBAL",1)
    Global("cd_no_travel_jugg_all","GLOBAL",0)
    Global("cd_no_travel_jugg_baeloth","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("%Beregost%")~                        // not in the area where the NPC will be sent
THEN REPLY @20848  GOTO dmww_beregost

IF ~Global("BD0120_START","GLOBAL",0)
    GlobalGT("Chapter","GLOBAL",1)
    Global("cd_no_travel_nashi_all","GLOBAL",0)
    Global("cd_no_travel_nashi_baeloth","GLOBAL",0)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("%Nashkel%")~                         // not in the area where the NPC will be sent
THEN REPLY @20847  GOTO dmww_nash

IF ~Global("BD0120_START","GLOBAL",0)
    OR(2)
      !Global("Chapter","GLOBAL",7)     // you're not wanted in the Gate for murder
      GlobalGT("DukeThanks","GLOBAL",0) // or you've been cleared by the Duke
    Global("cd_no_travel_esong_all","GLOBAL",0)
    Global("cd_no_travel_esong_baeloth","GLOBAL",0)
    Global("EnteredBaldursGate","GLOBAL",1)
    !Global("IslandTravel","GLOBAL",1)
    !Global("teth","GLOBAL",1)
    !Global("teth","GLOBAL",2)
    !AreaCheck("%DurlagsTower_Chessboard%")          // Chess Board
    !AreaCheck("%DurlagsTower_IceChamber%")          // Ice Node
    !AreaCheck("%DurlagsTower_FireChamber%")         // Fire Node
    !AreaCheck("%DurlagsTower_AirChamber%")          // Air Node
    !AreaCheck("%DurlagsTower_EarthChamber%")        // Earth Node
    !AreaCheck("%DurlagsTower_D2%")                  // Lower 3
    !AreaCheck("%DurlagsTower_D3%")                  // Lower 4
    !AreaCheck("%DurlagsTower_D4%")                  // Lower 5
    !AreaCheck("%DurlagsTower_CompassRoom%")         // Statue Room
    !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
    !AreaCheck("%IceIsland%")                        // ice isle surface
    !AreaCheck("%IceIslandMaze_L1%")                 // ice isle cavern 1
    !AreaCheck("%IceIslandMaze_L2%")                 // ice isle cavern 2
    !AreaCheck("%EBaldursGate%")~                    // not in the area where the NPC will be sent
THEN REPLY @20849  GOTO dmww_elfsong
END

APPEND baelothp
IF ~~ THEN BEGIN dmww_fai
  SAY @20851
  IF ~~ THEN DO ~EscapeAreaMove("%FriendlyArmInn%",4721,3045,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_beregost
  SAY @20851
  IF ~~ THEN DO ~EscapeAreaMove("%Beregost%",829,2427,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_nash
  SAY @20851
  IF ~~ THEN DO ~EscapeAreaMove("%Nashkel%",432,1288,0)~
EXIT
END

IF
  ~~ THEN BEGIN dmww_elfsong
  SAY @20851
  IF ~~ THEN DO ~EscapeAreaMove("%EBaldursGate%",353,1623,0)~
EXIT
END

END
