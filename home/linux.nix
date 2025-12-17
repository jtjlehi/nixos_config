{ ... }:
{
  imports = [
    ./window-manager
    ./default.nix
  ];
  systemd.user.enable = true;
}
