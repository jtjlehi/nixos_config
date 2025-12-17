{
  pkgs,
  lib,
  config,
  ...
}:
let

  /*
    Creates an option to include a single package

    That option can than be directly appended to the list of packages
  */
  mkIncludePkgOption =
    name: default:
    lib.mkOption {
      inherit default;
      example = !default;
      description = "Whether to include the ${name} package. (defaults to ${default})";
      type = lib.types.bool;
      apply = enable: lib.optional enable pkgs.${name};
    };
  pkgConfig = config.packages;
in
{
  imports = [
    ./python.nix
  ];

  options.packages = {
    chat = {
      mattermost.enable = mkIncludePkgOption "mattermost-desktop" false;
      slack.enable = mkIncludePkgOption "slack" false;
    };
    networking.wireguard-tools.enable = mkIncludePkgOption "wireguard-tools" false;
  };

  config.environment.systemPackages =
    with pkgs;
    [
      # compilers
      cmake
      gcc
      zig
      gnumake
      # lsps
      clang-tools # for clangd
      lemminx
      vhdl-ls
      nixd
      # rust
      (rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
      })
      # cli tools
      git
      gh
      ripgrep
      nushell
      zsh
      pulseaudio
      bear
      unzip
      bat
      calc
      jq
      helix
      # plotting and diagrams and visuals and stuff
      gnuplot
      # typst and stuff
      typst
      tinymist
      # podman/docker
      podman-tui
      podman-compose
      # gui tools
      brave
      meld
    ]
    ++ (lib.optionals stdenv.isLinux [
      perf
      valgrind
      eog
    ])
    ++ (lib.optionals stdenv.isDarwin [ ])
    ++ pkgConfig.chat.mattermost.enable
    ++ pkgConfig.chat.slack.enable
    ++ pkgConfig.networking.wireguard-tools.enable;
}
