// dupe transitions for the two acceptance routes
EXTEND_BOTTOM LAVOK 30
  COPY_TRANS LAVOK 30
END 
EXTEND_BOTTOM LAVOK 62
  COPY_TRANS LAVOK 62
END 

ALTER_TRANS LAVOK BEGIN 30 62 END BEGIN 0 END BEGIN ~REPLY~ ~@116024~ END // add reply to acceptance
ALTER_TRANS LAVOK BEGIN 30 62 END BEGIN 1 END BEGIN ~REPLY~ ~@116025~ END // add reply to declination
REPLACE_TRANS_ACTION LAVOK BEGIN 30 62 END BEGIN 1 END // for declination reply
  ~SetGlobal("PCSphere","GLOBAL",1)~                   // change acceptance var
  ~SetGlobal("cd_declined_sphere","GLOBAL",1)~         // to declination var
REPLACE_TRANS_ACTION LAVOK BEGIN 30 62 END BEGIN 1 END // for declination reply
  ~SetGlobal("PlayerHasStronghold","GLOBAL",1)~ ~~     // also don't set the has-stronghold var