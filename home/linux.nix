{ pkgs, lib, ... }: pkgs.stdenv.isLinux {
  imports =
    [
      ./window-manager
    ];
  systemd.user.enable = true;
}
