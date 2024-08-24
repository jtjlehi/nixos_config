{pkgs, ...}: let
  bwsBuildServer = {
    hostName = "anduril@192.168.70.9";
    system = "aarch64-linux";
    sshKey = "/root/.ssh/nixos_build_server_key";
    maxJobs = 64;
    speedFactor = 64;
    supportedFeatures = ["big-parallel" "kvm" "benchmark"];
  };
in {
  imports = [hardware/iron.nix];
  anduril-security = {
    kolide-launcher.enable = true;
    cloudflare-warp.enable = true;
  };
  environment.systemPackages = with pkgs; [
    slack
  ];
  boot.initrd.luks.devices."luks-57691d44-253b-4274-a395-e1de76de708d".device = "/dev/disk/by-uuid/57691d44-253b-4274-a395-e1de76de708d";
  # the cachix setup is not completely declarative
  nix = {
    settings = rec {
      substituters = [
        "https://cache.nixos.org/"
        # cache for haskell.nix
        "https://cache.iog.io"
        # caches for anduril
        "https://anduril-core-nix-cache.cachix.anduril.dev"
        "https://anduril-pulsar-nix-cache.cachix.anduril.dev"
      ];
      trusted-substituters = substituters;
      builders-use-substitutes = true;
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "anduril-core-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
        "anduril-pulsar-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
        "polyrepo.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
      ];
    };
    distributedBuilds = true;
    buildMachines = [bwsBuildServer];
  };
  programs.ssh.extraConfig = ''
    Host ghe.anduril.dev
      HostName ghe.anduril.dev
      User git
  '';
  home-manager.users."yajj" = {config, ...}:  {
    scripts = let
      ssh-to = name: {hostName, sshKey, ...}: {
        name = "ssh-${name}";
        text = /*bash*/ ''ssh -i ${sshKey} ${hostName}'';
      };
    in [
      (ssh-to "bws-build" bwsBuildServer)
      {
        name = "warp-reconnect";
        text = /*bash*/ "warp-cli disconnect && warp-cli connect";
      }
    ];

    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "ghe.anduril.dev" = {
        hostname = "ghe.anduril.dev";
        user = "git";
      };
      bws-flashing = {
        hostname = "192.168.70.15";
        user = "anduril";
      };
      system-manager = {
        hostname = "192.168.3.5";
        user = "anduril";
      };
      nx-top-ext = {
        hostname = "192.168.3.211";
        user = "anduril";
        proxyJump = "bws-flashing";
      };
      rfsom-top-ext = {
        hostname = "192.168.3.11";
        user = "anduril";
        proxyJump = "bws-flashing";
      };
      nx-top-int = {
        hostname = "192.168.3.210";
        user = "anduril";
        proxyJump = "bws-flashing";
      };
      rfsom-top-int = {
        hostname = "192.168.3.10";
        user = "anduril";
        proxyJump = "bws-flashing";
      };
    };
  };

}
