{ pkgs, lib, ... }: {
  imports = [
    ./window-manager
    ./shell
    ./zellij
    ./gtk.nix
    ./helix.nix
    # ./nvim
  ];
  home.username = "yajj";
  home.homeDirectory = "/home/yajj";

  systemd.user.enable = true;

  # git
  programs.git = {
    enable = true;
    userName = "neoj";
    userEmail = "jtjlehi@gmail.com";
    lfs.enable = true;
    extraConfig = {
      difftool  = {
        prompt = false;
        "meld" = {
          cmd = "meld \"$LOCAl\" \"$REMOTE\"";
        };
      };
    };
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
  programs.foot.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # compilers
    cmake
    gcc
    zig
    gnumake
    # rust
    (rust-bin.stable.latest.default.override {
      extensions = ["rust-src" "rust-analyzer"];
    })
    # desktop/tui stuff
    brave
    signal-desktop
    xplr
    meld
    calc
    jq
  ];

  stylix.autoEnable = true;

  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.home-manager.path = lib.mkForce "/home/yajj/.dotfiles/nixos";
}
