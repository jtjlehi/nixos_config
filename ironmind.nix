{pkgs, ...}: {
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
  nix.settings = let
    subs = [
      "https://cache.nixos.org/"
      "https://anduril-pulsar-nix-cache.cachix.anduril.dev/"
      "https://anduril-core-nix-cache.cachix.anduril.dev/"
    ];
  in {
    substituters = subs;
    trusted-substituters = subs;
    builders-use-substitutes = true;
    trusted-public-keys = [
      "anduril-core-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
      "anduril-pulsar-nix-cache.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
      "polyrepo.cachix.anduril.dev-1:0FYOuMqEzbSX2PmByfePpJAsSV6CW+1YWoq7b21NxHc="
    ];
    builders = "@/etc/nix/machines";
  };
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "ssh://anduril@192.168.70.9";
      system = "aarch64-linux";
      sshKey = "/root/.ssh/nixos_build_server_key";
      maxJobs = 64;
      speedFactor = 64;
      supportedFeatures = ["big-parallel" "kvm" "benchmark"];
    }
  ];
}
