ALTER_TRANS BOTSMITH BEGIN 4 9 15 19 23 27 31 35 39 43 47 51 55 END BEGIN 22 END // filename, state, trans
  BEGIN TRIGGER ~OR(3) PartyHasItem("sw1h70") PartyHasItem("cdkt25") PartyHasItem("c!kt25")~ END

ADD_TRANS_ACTION BOTSMITH BEGIN 58 END BEGIN 1 END ~TakePartyItem("cdkt25") TakePartyItem("c!kt25") DestroyItem("cdkt25") DestroyItem("c!kt25")~
