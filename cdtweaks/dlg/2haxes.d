ALTER_TRANS BOTSMITH BEGIN 4 9 15 19 23 27 31 35 39 END BEGIN 26 END // filename, state, trans
  BEGIN TRIGGER ~OR(3) PartyHasItem("ax1h14") PartyHasItem("cdax8") PartyHasItem("c!ax8")~ END

ADD_TRANS_ACTION BOTSMITH BEGIN 42 END BEGIN 1 END ~TakePartyItem("cdax8") TakePartyItem("c!ax8") DestroyItem("cdax8") DestroyItem("c!ax8")~
