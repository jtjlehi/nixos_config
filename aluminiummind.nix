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
  home-manager.users.${config.username} = { ... }: {
    programs.git.settings.user = lib.mkForce {
      name = "neoj";
      email = "jjacobson.ctr@anduril.com";
    };
  };
}
