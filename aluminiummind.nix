{
  config,
  lib,
  ...
}:
{
  imports = [ ./hardware/aluminiummind ];

  users.users.${config.username} = {
    hashedPassword = lib.mkForce null;
    home = "/home/jjacobson";
  };
}
