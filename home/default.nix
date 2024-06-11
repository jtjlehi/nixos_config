{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./window-manager
    ./shell
    ./zellij
    ./gtk.nix
    ./nvim
  ];
  home.username = "yajj";
  home.homeDirectory = "/home/yajj";

  systemd.user.enable = true;

  # git
  programs.git = {
    enable = true;
    userName = "jtjlehi";
    userEmail = "jtjlehi@gmail.com";
  };
  programs.gh.enable = true;
  programs.foot.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # compilers
    zig
    gcc
    ghc
    # rust
    cargo
    rustc
    clippy
    # desktop/tui stuff
    firefox
    brave
    signal-desktop
    xplr
  ];

  stylix.autoEnable = true;

  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = lib.mkForce "/home/yajj/.dotfiles/nixos";
}
