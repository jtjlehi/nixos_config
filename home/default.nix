{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./fonts.nix
    ./window-manager
    ./shell
    ./zellij
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # compilers
    zig
    gcc
    # rust
    cargo
    rustc
    clippy
    rust-analyzer
    rustfmt
    # language servers
    lua-language-server
    nil # nix language server
    alejandra # auto-formatter for nix
    # desktop stuff
    firefox
    neovim
    signal-desktop
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = lib.mkForce "$HOME/.dotfiles/nixos";
}
