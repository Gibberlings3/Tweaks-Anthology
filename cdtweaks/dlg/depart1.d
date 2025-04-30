EXTEND_BOTTOM ~dmwwscriptname~ dmwwstatenumber

  IF ~Global("EnteredArmInn","GLOBAL",1)
      !Global("IslandTravel","GLOBAL",1) // not on Werewolf Isle
      !Global("teth","GLOBAL",1) // not trapped under Candlekeep AR2613, 2615, 2619, 5506
      !Global("teth","GLOBAL",2)
      !AreaCheck("%GnollStronghold%") // Gnoll Stronghold
      !AreaCheck("%GnollStronghold_XvartCave%") // Gnoll Stronghold Xvart Cave
      !AreaCheck("%GnollStronghold_TomeCave%") // Gnoll Stronghold Treasure Cave
      !AreaCheck("%GnollStronghold_CrawlerCave%") // Gnoll Stronghold Carrion Crawler Cave
      !AreaCheck("%DurlagsTower_Chessboard%") // Chess Board
      !AreaCheck("%DurlagsTower_IceChamber%") // Ice Node
      !AreaCheck("%DurlagsTower_FireChamber%") // Fire Node
      !AreaCheck("%DurlagsTower_AirChamber%") // Air Node
      !AreaCheck("%DurlagsTower_EarthChamber%") // Earth Node
      !AreaCheck("%DurlagsTower_D1%") // Lower 2
      !AreaCheck("%DurlagsTower_D2%") // Lower 3
      !AreaCheck("%DurlagsTower_D3%") // Lower 4
      !AreaCheck("%DurlagsTower_D4%") // Lower 5
      !AreaCheck("%DurlagsTower_CompassRoom%") // Statue Room
      !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
      !AreaCheck("%IceIsland%") // ice isle surface
      !AreaCheck("%IceIslandMaze_L1%") // ice isle cavern 1
      !AreaCheck("%IceIslandMaze_L2%") // ice isle cavern 2
      !AreaCheck("%FriendlyArmInn_L1%") // not in the area where the NPC will be sent
      !Global("Z!EmulAreaCheck","GLOBAL","5100") // Gnoll Stronghold
      !Global("Z!EmulAreaCheck","GLOBAL","5101") // Gnoll Stronghold Xvart Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5102") // Gnoll Stronghold Treasure Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5103") // Gnoll Stronghold Carrion Crawler Cave
      !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
      !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
      !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
      !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
      !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
      !Global("Z!EmulAreaCheck","GLOBAL","0511") // lower 2
      !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
      !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
      !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
      !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
      !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
      !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
      !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
      !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
      !Global("Z!EmulAreaCheck","GLOBAL","2301")~ // not in the area where the NPC will be sent
    THEN REPLY @107501 GOTO dmww_fai

  IF ~Global("EnteredBeregost","GLOBAL",1)
      !Global("IslandTravel","GLOBAL",1)
      !Global("teth","GLOBAL",1)
      !Global("teth","GLOBAL",2)
      !AreaCheck("%GnollStronghold%") // Gnoll Stronghold
      !AreaCheck("%GnollStronghold_XvartCave%") // Gnoll Stronghold Xvart Cave
      !AreaCheck("%GnollStronghold_TomeCave%") // Gnoll Stronghold Treasure Cave
      !AreaCheck("%GnollStronghold_CrawlerCave%") // Gnoll Stronghold Carrion Crawler Cave
      !AreaCheck("%DurlagsTower_Chessboard%") // Chess Board
      !AreaCheck("%DurlagsTower_IceChamber%") // Ice Node
      !AreaCheck("%DurlagsTower_FireChamber%") // Fire Node
      !AreaCheck("%DurlagsTower_AirChamber%") // Air Node
      !AreaCheck("%DurlagsTower_EarthChamber%") // Earth Node
      !AreaCheck("%DurlagsTower_D1%") // Lower 2
      !AreaCheck("%DurlagsTower_D2%") // Lower 3
      !AreaCheck("%DurlagsTower_D3%") // Lower 4
      !AreaCheck("%DurlagsTower_D4%") // Lower 5
      !AreaCheck("%DurlagsTower_CompassRoom%") // Statue Room
      !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
      !AreaCheck("%IceIsland%") // ice isle surface
      !AreaCheck("%IceIslandMaze_L1%") // ice isle cavern 1
      !AreaCheck("%IceIslandMaze_L2%") // ice isle cavern 2
      !AreaCheck("%Beregost_JovialJuggler_L1%") // not in the area where the NPC will be sent
      !Global("Z!EmulAreaCheck","GLOBAL","5100") // Gnoll Stronghold
      !Global("Z!EmulAreaCheck","GLOBAL","5101") // Gnoll Stronghold Xvart Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5102") // Gnoll Stronghold Treasure Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5103") // Gnoll Stronghold Carrion Crawler Cave
      !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
      !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
      !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
      !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
      !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
      !Global("Z!EmulAreaCheck","GLOBAL","0511") // lower 2
      !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
      !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
      !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
      !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
      !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
      !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
      !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
      !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
      !Global("Z!EmulAreaCheck","GLOBAL","3304")~ // not in the area where the NPC will be sent
    THEN REPLY @107502  GOTO dmww_beregost

  IF ~GlobalGT("Chapter","GLOBAL",1)
      !Global("IslandTravel","GLOBAL",1)
      !Global("teth","GLOBAL",1)
      !Global("teth","GLOBAL",2)
      !AreaCheck("%GnollStronghold%") // Gnoll Stronghold
      !AreaCheck("%GnollStronghold_XvartCave%") // Gnoll Stronghold Xvart Cave
      !AreaCheck("%GnollStronghold_TomeCave%") // Gnoll Stronghold Treasure Cave
      !AreaCheck("%GnollStronghold_CrawlerCave%") // Gnoll Stronghold Carrion Crawler Cave
      !AreaCheck("%DurlagsTower_Chessboard%") // Chess Board
      !AreaCheck("%DurlagsTower_IceChamber%") // Ice Node
      !AreaCheck("%DurlagsTower_FireChamber%") // Fire Node
      !AreaCheck("%DurlagsTower_AirChamber%") // Air Node
      !AreaCheck("%DurlagsTower_EarthChamber%") // Earth Node
      !AreaCheck("%DurlagsTower_D1%") // Lower 2
      !AreaCheck("%DurlagsTower_D2%") // Lower 3
      !AreaCheck("%DurlagsTower_D3%") // Lower 4
      !AreaCheck("%DurlagsTower_D4%") // Lower 5
      !AreaCheck("%DurlagsTower_CompassRoom%") // Statue Room
      !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
      !AreaCheck("%IceIsland%") // ice isle surface
      !AreaCheck("%IceIslandMaze_L1%") // ice isle cavern 1
      !AreaCheck("%IceIslandMaze_L2%") // ice isle cavern 2
      !AreaCheck("%Nashkel_Inn%") // not in the area where the NPC will be sent
      !Global("Z!EmulAreaCheck","GLOBAL","5100") // Gnoll Stronghold
      !Global("Z!EmulAreaCheck","GLOBAL","5101") // Gnoll Stronghold Xvart Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5102") // Gnoll Stronghold Treasure Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5103") // Gnoll Stronghold Carrion Crawler Cave
      !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
      !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
      !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
      !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
      !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
      !Global("Z!EmulAreaCheck","GLOBAL","0511") // lower 2
      !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
      !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
      !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
      !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
      !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
      !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
      !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
      !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
      !Global("Z!EmulAreaCheck","GLOBAL","4801")~ // not in the area where the NPC will be sent
    THEN REPLY @107503  GOTO dmww_nash

  IF ~!Global("Chapter","GLOBAL",7)   // you're not wanted in the Gate for murder
      Global("EnteredBaldursGate","GLOBAL",1)
      !Global("IslandTravel","GLOBAL",1)
      !Global("teth","GLOBAL",1)
      !Global("teth","GLOBAL",2)
      !AreaCheck("%GnollStronghold%") // Gnoll Stronghold
      !AreaCheck("%GnollStronghold_XvartCave%") // Gnoll Stronghold Xvart Cave
      !AreaCheck("%GnollStronghold_TomeCave%") // Gnoll Stronghold Treasure Cave
      !AreaCheck("%GnollStronghold_CrawlerCave%") // Gnoll Stronghold Carrion Crawler Cave
      !AreaCheck("%DurlagsTower_Chessboard%") // Chess Board
      !AreaCheck("%DurlagsTower_IceChamber%") // Ice Node
      !AreaCheck("%DurlagsTower_FireChamber%") // Fire Node
      !AreaCheck("%DurlagsTower_AirChamber%") // Air Node
      !AreaCheck("%DurlagsTower_EarthChamber%") // Earth Node
      !AreaCheck("%DurlagsTower_D1%") // Lower 2
      !AreaCheck("%DurlagsTower_D2%") // Lower 3
      !AreaCheck("%DurlagsTower_D3%") // Lower 4
      !AreaCheck("%DurlagsTower_D4%") // Lower 5
      !AreaCheck("%DurlagsTower_CompassRoom%") // Statue Room
      !AreaCheck("%DurlagsTower_DemonknightsChamber%") // Demon Knight
      !AreaCheck("%IceIsland%") // ice isle surface
      !AreaCheck("%IceIslandMaze_L1%") // ice isle cavern 1
      !AreaCheck("%IceIslandMaze_L2%") // ice isle cavern 2
      !AreaCheck("%EBaldursGate_ElfsongTavern_L1%") // not in the area where the NPC will be sent
      !Global("Z!EmulAreaCheck","GLOBAL","5100") // Gnoll Stronghold
      !Global("Z!EmulAreaCheck","GLOBAL","5101") // Gnoll Stronghold Xvart Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5102") // Gnoll Stronghold Treasure Cave
      !Global("Z!EmulAreaCheck","GLOBAL","5103") // Gnoll Stronghold Carrion Crawler Cave
      !Global("Z!EmulAreaCheck","GLOBAL","0506") // Chess Board
      !Global("Z!EmulAreaCheck","GLOBAL","0507") // Ice Node
      !Global("Z!EmulAreaCheck","GLOBAL","0508") // Fire Node
      !Global("Z!EmulAreaCheck","GLOBAL","0509") // Air Node
      !Global("Z!EmulAreaCheck","GLOBAL","0510") // Earth Node
      !Global("Z!EmulAreaCheck","GLOBAL","0511") // lower 2
      !Global("Z!EmulAreaCheck","GLOBAL","0512") // Lower 3
      !Global("Z!EmulAreaCheck","GLOBAL","0513") // Lower 4
      !Global("Z!EmulAreaCheck","GLOBAL","0514") // Lower 5
      !Global("Z!EmulAreaCheck","GLOBAL","0515") // Statue Room
      !Global("Z!EmulAreaCheck","GLOBAL","0516") // Demon Knight
      !Global("Z!EmulAreaCheck","GLOBAL","1008") // ice isle surface
      !Global("Z!EmulAreaCheck","GLOBAL","1009") // ice isle cavern 1
      !Global("Z!EmulAreaCheck","GLOBAL","1010") // ice isle cavern 2
      !Global("Z!EmulAreaCheck","GLOBAL","0705")~ // not in the area where the NPC will be sent
    THEN REPLY @107504  GOTO dmww_elfsong
END

APPEND ~dmwwscriptname~

  IF ~~ THEN BEGIN dmww_fai SAY dmwwresponse
    IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120) Face(0) MoveGlobal("AR2301","z!deathvariable",dmwwfailoc)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_beregost SAY dmwwresponse
    IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120) Face(0) MoveGlobal("AR3304","z!deathvariable",dmwwbereloc)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_nash SAY dmwwresponse
    IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120) Face(0) MoveGlobal("AR4801","z!deathvariable",dmwwnashloc)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_elfsong SAY dmwwresponse
    IF ~~ THEN DO ~RunAwayFromNoInterrupt([PC],120) Face(0) MoveGlobal("AR0705","z!deathvariable",dmwwelfloc)~ EXIT
  END

END
