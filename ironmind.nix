{pkgs, ...}: let
  rootBwsBuildServer = {
    hostName = "anduril@192.168.70.9";
    system = "aarch64-linux";
    sshKey = "/root/.ssh/nixos_build_server_key";
    maxJobs = 64;
    speedFactor = 64;
    supportedFeatures = ["big-parallel" "kvm" "benchmark"];
  };
  bwsBuildServer = rootBwsBuildServer // {
    sshKey = "~/.ssh/nixos_build_server_key";
  };
  andurilBuildArm = {
    hostName = "anduril@dev-pulsar-arm.anduril.dev";
    system = "aarch64-linux";
    sshKey = "home/yajj/.ssh/id_ed25519";
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
  nix = {
    settings = let
      trustedSubs = {
        # cache for haskell.nix
        "https://cache.iog.io" = "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
        # caches for anduril
        "https://anduril-core-nix-cache.cachix.anduril.dev" = "anduril-core-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc=";
        "https://anduril-pulsar-nix-cache.cachix.anduril.dev" = "anduril-pulsar-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc=";
      };
      substituters = builtins.attrNames trustedSubs;
      trusted-public-keys = builtins.attrValues trustedSubs;
    in {
      inherit substituters trusted-public-keys;
      # the netrc file holds the passwords generated from `cachix use ...`, (I delete the rest of the files cachix generates)
      netrc-file = "/etc/nix/netrc";
      trusted-substituters = substituters ++ [ "https://cache.nixos.org/" ];
      builders-use-substitutes = true;
    };
    distributedBuilds = true;
    buildMachines = [rootBwsBuildServer andurilBuildArm];
  };
  programs.ssh.extraConfig = ''
    Host ghe.anduril.dev
      HostName ghe.anduril.dev
      User git
  '';
  home-manager.users."yajj" = {config, lib, ...}:  {
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
    programs.git = lib.mkForce {
      userName = "neoj";
      userEmail = "jjacobson.ctr@anduril.com";
    };

    programs.ssh.enable = true;
    programs.ssh.matchBlocks = let
      vck = proxyJump: rec {
        inherit proxyJump;
        hostname = "192.168.3.90";
        user = "anduril";
        # checkHostIP = false;
        localForwards = [
          { bind.port = 2020; host.address = hostname; host.port = 2020; }
        ];
        extraOptions = {
          "StrictHostKeyChecking" = "no";
          "UserKnownHostsFile" = "/dev/null";
        };
      };
    in {
      anduril-build-x86 = {
        hostname = "anduril@dev-pulsar-x86.anduril.dev";
        user = "anduril";
      };
      anduril-build-arm = {
        hostname = "anduril@dev-pulsar-arm.anduril.dev";
        user = "anduril";
      };
      "ghe.anduril.dev" = {
        hostname = "ghe.anduril.dev";
        user = "git";
      };
      flashing1 = {
        hostname = "192.168.70.13";
        user = "anduril";
      };
      flashing2 = {
        hostname = "192.168.70.14";
        user = "anduril";
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
      vck1 = vck "flashing1";
      vck2 = vck "flashing2";
      vck3 = vck "bws-flashing";
      bws-build = {
        hostname = "192.168.70.9";
        user = "anduril";
        identityFile = "~/.ssh/nixos_build_server_key";
        certificateFile = "~/.ssh/nixos_build_server_key";
      };
    };
  };

}
