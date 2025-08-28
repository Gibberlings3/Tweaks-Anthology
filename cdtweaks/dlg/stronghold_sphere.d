// class checks altered to be always true; playerhasstronghold removed in other d file
REPLACE_TRIGGER_TEXT ~lavok~    ~Class(Player1,\([A-Z]+_\)*MAGE\(_[A-Z]+\)?)~ ~True()~

// don't let knights leave unless you've formally declined the sphere
REPLACE_TRIGGER_TEXT ~obssol01~ ~!Class(Player1,\([A-Z]+_\)*MAGE\(_[A-Z]+\)?)~ ~Global("cd_declined_sphere","GLOBAL",1)~
