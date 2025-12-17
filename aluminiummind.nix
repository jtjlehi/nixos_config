{
  config,
  lib,
  ...
}:
{
  imports = [ ./hardware/aluminiummind ];
  programs.sway.enable = lib.mkForce false;
  xdg.portal.enable = lib.mkForce false;

  users.users.${config.username} = {
    home = "/home/jjacobson";
  };
}
