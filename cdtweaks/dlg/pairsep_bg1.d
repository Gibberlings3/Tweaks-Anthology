EXTEND_BOTTOM ~JAHEIP~ ~4~

IF ~!StateCheck("khalid",CD_STATE_NOTVALID) Range("khalid",1000)~ THEN REPLY @20700   EXTERN ~KHALIP~ dmww_khalidnotwanted
END

CHAIN
IF ~~ THEN KHALIP dmww_khalidnotwanted
@20701 == JAHEIP
@20702
DO ~ JoinParty()~ EXIT

EXTEND_BOTTOM ~KHALIP~ 5

IF ~!StateCheck("jaheira",CD_STATE_NOTVALID) Range("jaheira",1000)~ THEN REPLY @20703 GOTO dmww_jaheiranotwanted
END

CHAIN
IF ~~ THEN KHALIP dmww_jaheiranotwanted
@20704 == JAHEIP
@20705
DO ~ActionOverride("khalid",JoinParty())~ EXIT

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXTEND_BOTTOM ~MINSCP~ 4

IF ~!StateCheck("dynaheir",CD_STATE_NOTVALID)Range("dynaheir",1000)~ THEN REPLY @20706 GOTO dmww_dynaheirnotwanted
END

CHAIN
IF ~~ THEN MINSCP dmww_dynaheirnotwanted
@20707 == DYNAHP
@20708
DO ~ActionOverride("minsc",JoinParty())~
EXIT

EXTEND_BOTTOM ~DYNAHP~ 4

IF ~!StateCheck("minsc",CD_STATE_NOTVALID)~ THEN REPLY @20709 EXTERN ~MINSCP~ dmww_minscnotwanted
END

CHAIN
IF ~~ THEN MINSCP dmww_minscnotwanted
@20710 == DYNAHP
@20711
DO ~ JoinParty() ~ EXIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


EXTEND_BOTTOM ~MONTAP~ 5

IF ~!StateCheck("xzar",CD_STATE_NOTVALID)Range("xzar",1000)~ THEN REPLY @20712 EXTERN ~XZARP~ dmww_xzarnotwanted
END

CHAIN
IF ~~ THEN XZARP dmww_xzarnotwanted
@20713 == MONTAP
@20714
DO ~ JoinParty() ~ EXIT

EXTEND_BOTTOM ~XZARP~ 5

IF ~!StateCheck("montaron",CD_STATE_NOTVALID) Range("montaron",1000)~ THEN REPLY @20715 GOTO dmww_montaronnotwanted
END

CHAIN
IF ~~ THEN XZARP dmww_montaronnotwanted
@20716 == MONTAP
@20717
DO ~ActionOverride("xzar",JoinParty())~ EXIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

EXTEND_BOTTOM ~ELDOTP~ 4

IF ~!StateCheck("skie",CD_STATE_NOTVALID) Range("skie",1000)~ THEN REPLY @20726 GOTO dmww_skienotwanted
END

CHAIN
IF ~~ THEN ELDOTP dmww_skienotwanted
@20718 = @20719 == SKIEP
@20720 = @20721
DO ~ActionOverride("eldoth",JoinParty())~
EXIT

EXTEND_BOTTOM ~SKIEP~ 4

IF ~!StateCheck("eldoth",CD_STATE_NOTVALID) Range("eldoth",1000)~ THEN REPLY @20725 GOTO dmww_eldothnotwanted
END

CHAIN
IF ~~ THEN SKIEP dmww_eldothnotwanted
@20722 == ELDOTP
@20723=@20724
DO ~ActionOverride("skie",JoinParty())~
EXIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ALTER_TRANS JAHEIP BEGIN 6 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS KHALIP BEGIN 6 END BEGIN 0 END BEGIN "ACTION" "" END
//ALTER_TRANS MINSCP BEGIN 999 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS DYNAHP BEGIN 6 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS MONTAP BEGIN 7 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS XZARP BEGIN 6 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS ELDOTP BEGIN 8 END BEGIN 0 END BEGIN "ACTION" "" END
ALTER_TRANS SKIEP BEGIN 6 END BEGIN 0 END BEGIN "ACTION" "" END

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// this is a suboptimal approach... since these post dialogues only have two available states, but I have no OR trigger, I'm making the one
// that should be OR(3)Dead(x)InParty(x)!InMyArea(x) as True and simply WEIGHTing it below the other if needed.
ADD_STATE_TRIGGER DYNAHP 4 ~Range("Minsc",1000) !InParty("Minsc")~
ADD_STATE_TRIGGER ELDOTP 4 ~Range("Skie",1000) !InParty("Skie")~
ADD_STATE_TRIGGER JAHEIP 4 ~Range("khalid",1000) !InParty("khalid")~
ADD_STATE_TRIGGER KHALIP 5 ~Range("Jaheira",1000) !InParty("Jaheira")~
ADD_STATE_TRIGGER MINSCP 4 ~Range("Dynaheir",1000) !InParty("Dynaheir")~
ADD_STATE_TRIGGER MONTAP 5 ~Range("XZAR",1000) !InParty("XZAR")~
ADD_STATE_TRIGGER SKIEP  4 ~Range("Eldoth",1000) !InParty("Eldoth")~
ADD_STATE_TRIGGER XZARP  5 ~Range("Montaron",1000) !InParty("Montaron")~

REPLACE_STATE_TRIGGER DYNAHP 5 ~True()~
REPLACE_STATE_TRIGGER ELDOTP 5 ~True()~
REPLACE_STATE_TRIGGER JAHEIP 5 ~True()~
REPLACE_STATE_TRIGGER KHALIP 4 ~True()~ // needs reweighting
REPLACE_STATE_TRIGGER MINSCP 5 ~True()~
REPLACE_STATE_TRIGGER MONTAP 4 ~True()~ // needs reweighting
REPLACE_STATE_TRIGGER SKIEP  5 ~True()~
REPLACE_STATE_TRIGGER XZARP  4 ~True()~ // needs reweighting


SET_WEIGHT KHALIP 4 #999
SET_WEIGHT MONTAP 4 #999
SET_WEIGHT XZARP 4 #999
