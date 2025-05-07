/* alright, so the deal: tracked down all of the bitchy exchanges between the romance partners. The list:
Aerie:
  LT 4, state 130 (I... I have been looking at the scars... on my back. The stumps that were... that were once my wings. They do not... they do not make me truly homely, do they? Am I... am I ugly to you?)
    - bitchy but harmless exchange with Viconia or Jaheira
  LT 7, state 167 (Have you traveled much? I have been over much of Amn and Tethyr with the circus... although it was not always the most pleasant way to voyage.)
    - bitchy but harmless exchange with Viconia or Jaheira
  LT 9, state 201 (I have been thinking... I shall never fly again... never taste the freedom of my wings, I am sure of it. I... I don't know if I can face this wretched existence on the ground...!)
    - bitchy but harmless exchange with Viconia or Jaheira
  LT 13, state 232>233 (We're—we're stopping? *sob* I just feel like collapsing here and dying; I just don't think I can go on.)
    - if viconia is in the party, eventually forces choice in bviconi 547: reply 0,1 kills vic in bviconi 548, 549; reply 2,3 kills aerie in baerie 435/436 (also leaves in 436)
    - if vic not in party but jaheira is, eventually forces choice in bjaheir 435: reply 0,1 kills jahs in bjaheir 436, 437; reply 2,3 kills aerie in baerie 440/436 (also leaves in 436)

Jaheira
  LT 11, state 188 (I... I worry sometimes...)
    - bitchy but harmless exchange with Viconia or Aerie

Viconia
  LT 5, state 32 (I have been thinking a little. I've been thinking of the time I've spent with the rivvil... the humans... and I have found nothing redeeming or worthwhile in them.)
    - bitchy but harmless exchange with Jaheira or Aerie
  LT 8, state 62 (I have been thinking, and I think that I may have been exceedingly harsh in my treatment of you once again.)
    - bitchy but harmless exchange with Jaheira or Aerie
  LT 16, state 95 (Have I ever told you how it is that I came to flee from the Underdark?)
    - if jaheira is in the party, eventually forces choice in bjaheir 447: reply 0,1 kills jahs in bjaheir 448, 449; reply 2,3 kills vic in bviconi 565

all three decision points (bjaheir 437, 447 and bviconi 547) have the same four replies:
  1. mean reply to interjector, killing their romance
  2. polite rebuke to interjector, killing their romance
  3. polite rebuke to original speaker, killing their romance
  4. mean reply to original speaker, killing their romance (aerie also leaves if she gets the mean reply)

 we disable replies 1, 3, and 4 so that the original LT can continue, and remove the romance-killing code from all four branches (even though only one should be active)

*/

// for each of the three decision points, eliminate all but the semi-nice option to brush off the interjector so that the original LT can continue
ADD_TRANS_TRIGGER BJAHEIR 435 ~False()~ DO 0 2 3 // leaves only semi-nice rebuke to jaheira, continue aerie LT
ADD_TRANS_TRIGGER BJAHEIR 447 ~False()~ DO 0 2 3 // leaves only semi-nice rebuke to jaheira, continue viconia LT
ADD_TRANS_TRIGGER BVICONI 547 ~False()~ DO 0 2 3 // leaves only semi-nice rebuke to viconia, continue aerie LT

// these are all of the 'I didn't pick you, your romance is over' states. Delete the set=3 actions for all of them, even though we're already eliminating the path to most of these branches
// only 10 replies instead of 12 because bviconi 565 and baerie 436 get used twice
REPLACE_TRANS_ACTION BAERIE  BEGIN 435 436 440     END BEGIN END ~SetGlobal("AerieRomanceActive","GLOBAL",3)~   ~~
REPLACE_TRANS_ACTION BJAHEIR BEGIN 436 437 448 449 END BEGIN END ~SetGlobal("JaheiraRomanceActive","GLOBAL",3)~ ~~
REPLACE_TRANS_ACTION BVICONI BEGIN 548 549 565     END BEGIN END ~SetGlobal("ViconiaRomanceActive","GLOBAL",3)~ ~~


