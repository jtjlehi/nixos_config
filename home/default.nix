{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./shell
    ./zellij
    ./gtk.nix
    ./helix.nix
  ];
  home.username = lib.mkDefault "yajj";

  # git
  programs.git = {
    enable = true;
    settings = {
      user.name = "neoj";
      user.email = "jtjlehi@gmail.com";
      difftool = {
        prompt = false;
        "meld" = {
          cmd = "meld \"$LOCAl\" \"$REMOTE\"";
        };
      };
    };
    lfs.enable = true;
  };
  programs.gh.enable = true;
  programs.gh.gitCredentialHelper = {
    enable = true;
    hosts = [
      "https://github.com"
      "https://gist.github.com"
      "https://ghe.anduril.dev"
    ];
  };
  programs.foot.enable = pkgs.stdenv.isLinux;

  stylix.autoEnable = true;

  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = lib.mkForce "/home/${config.home.username}/.dotfiles/nixos";
}
