EXTEND_BOTTOM multig 1

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
      !AreaCheck("%FriendlyArmInn_L2%")~ // not in the area where the NPC will be sent
    THEN REPLY @107001 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO dmww_fai

  IF ~Global("EnteredBeregost","GLOBAL",1)
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
      !AreaCheck("%Beregost_JovialJuggler_L2R%")~ // not in the area where the NPC will be sent
    THEN REPLY @107015  DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO dmww_beregost

  IF ~GlobalGT("Chapter","GLOBAL",1)
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
      !AreaCheck("%Nashkel_TempleofHelm%")~ // not in the area where the NPC will be sent
    THEN REPLY @107013 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO dmww_nash

  IF ~!Global("Chapter","GLOBAL",7)   // you're not wanted in the Gate for murder
      Global("EnteredBaldursGate","GLOBAL",1)
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
      !AreaCheck("%EBaldursGate_ElfsongTavern_L2%")~ // not in the area where the NPC will be sent
    THEN REPLY @107014 DO ~SetGlobal("Waiting","LOCALS",1)~ GOTO dmww_elfsong

END

APPEND ~multig~

  IF ~~ THEN BEGIN dmww_fai SAY @107009
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",682,726,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",663,751,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",715,760,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",711,784,10)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",761,799,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",5)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",762,822,02)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",6)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",684,659,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",7)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",675,691,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",8)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",715,679,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",9)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",710,715,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",10)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",751,727,04)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",11)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",756,754,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",12)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Fai","GLOBAL",1) EscapeAreaMove("%FriendlyArmInn_L2%",796,750,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Fai","GLOBAL",13)~ THEN DO ~SetGlobal("CDMultiNPCNo_Fai","GLOBAL",0) EscapeAreaMove("%FriendlyArmInn_L2%",790,783,06)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_beregost
    SAY @107009
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",350,300,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",230,235,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",585,245,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",455,460,10)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",575,325,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",5)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",400,195,02)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",6)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",175,295,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",7)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",395,195,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",8)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",640,255,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",9)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",515,360,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",10)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",475,265,04)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",11)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",220,390,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",12)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Bereg","GLOBAL",1) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",410,400,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Bereg","GLOBAL",13)~ THEN DO ~SetGlobal("CDMultiNPCNo_Bereg","GLOBAL",0) EscapeAreaMove("%Beregost_JovialJuggler_L2R%",260,345,06)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_nash
    SAY @107009
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",250,410,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",215,435,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",260,440,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",285,410,10)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",485,550,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",5)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",455,575,02)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",6)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",415,540,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",7)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",460,495,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",8)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",340,300,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",9)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",310,330,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",10)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",355,330,04)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",11)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",575,440,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",12)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Nash","GLOBAL",1) EscapeAreaMove("%Nashkel_TempleofHelm%",540,480,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Nash","GLOBAL",13)~ THEN DO ~SetGlobal("CDMultiNPCNo_Nash","GLOBAL",0) EscapeAreaMove("%Nashkel_TempleofHelm%",500,450,06)~ EXIT
  END

  IF ~~ THEN BEGIN dmww_elfsong
    SAY @107009
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",0)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",825,420,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",1)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",775,355,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",2)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",730,390,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",3)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",765,415,10)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",4)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",710,460,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",5)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",745,500,02)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",6)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",760,450,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",7)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",815,510,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",8)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",255,570,12)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",9)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",305,545,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",10)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",300,600,04)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",11)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",450,725,14)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",12)~ THEN DO ~IncrementGlobal("CDMultiNPCNo_Elfsong","GLOBAL",1) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",490,700,00)~ EXIT
    IF ~Global("CDMultiNPCNo_Elfsong","GLOBAL",13)~ THEN DO ~SetGlobal("CDMultiNPCNo_Elfsong","GLOBAL",0) EscapeAreaMove("%EBaldursGate_ElfsongTavern_L2%",415,695,06)~ EXIT
  END

END
