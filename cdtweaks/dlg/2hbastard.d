ALTER_TRANS BOTSMITH BEGIN 4 9 15 19 END BEGIN 31 END // filename, state, trans
  BEGIN TRIGGER ~OR(3) PartyHasItem("sw1h64") PartyHasItem("cdbs13") PartyHasItem("c!bs13")~ END

ADD_TRANS_ACTION BOTSMITH BEGIN 22 END BEGIN 1 END ~TakePartyItem("cdbs13") TakePartyItem("c!bs13") DestroyItem("cdbs13") DestroyItem("c!bs13")~

ALTER_TRANS BOTSMITH BEGIN 4 9 15 END BEGIN 32 END // filename, state, trans
  BEGIN TRIGGER ~OR(3) PartyHasItem("sw1h62") PartyHasItem("cdbs11") PartyHasItem("c!bs11")~ END

ADD_TRANS_ACTION BOTSMITH BEGIN 18 END BEGIN 1 END ~TakePartyItem("cdbs11") TakePartyItem("c!bs11") DestroyItem("cdbs11") DestroyItem("c!bs11")~
