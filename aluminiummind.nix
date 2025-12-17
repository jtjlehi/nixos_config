{
  config,
  lib,
  ...
}:
{
  imports = [ ./hardware/aluminiummind ];

  users.users.${config.username} = {
    home = "/home/jjacobson";
  };
}
