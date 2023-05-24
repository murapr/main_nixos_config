let
  mur = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqfxDRtHtcmQUkLKA1x18nOLv7YHarcQXRpBX/YDDiA screwedmobile";
in {
  "finsocks.age".publicKeys = [ mur ];
  "frsocks.age".publicKeys = [ mur ];
  "cansocks.age".publicKeys = [ mur ];
  "mur_password.age".publicKeys = [ mur ]; 
}
