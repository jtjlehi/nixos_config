{pkgs, config,...}: let
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
  # andurilBuildArm = {
  #   hostName = "anduril@dev-pulsar-arm.anduril.dev";
  #   system = "aarch64-linux";
  #   sshKey = "home/yajj/.ssh/id_ed25519";
  #   maxJobs = 64;
  #   speedFactor = 64;
  #   supportedFeatures = ["big-parallel" "kvm" "benchmark"];
  # };
in {
  imports = [hardware/iron.nix];

  # GPU Stuff
  # (TODO: turn into an option)

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  # services.xserver.videoDrivers = ["nvidia"];

  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;

  #   # Use the NVidia open source kernel module (not to be confused with the
  #   # independent third-party "nouveau" open source driver).
  #   # Support is limited to the Turing and later architectures. Full list of 
  #   # supported GPUs is at: 
  #   # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
  #   # Only available from driver 515.43.04+
  #   # Currently alpha-quality/buggy, so false is currently the recommended setting.
  #   open = false;

  #   # Enable the Nvidia settings menu,
  # 	# accessible via `nvidia-settings`.
  #   nvidiaSettings = true;

  #   # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  #  hardware.nvidia.prime = {
  #   # Make sure to use the correct Bus ID values for your system!
	#   intelBusId = "PCI:0:2:0";
	#   nvidiaBusId = "PCI:1:0:0";
	# };

  # Anduril VPN stuff

  anduril-security = {
    kolide-launcher.enable = true;
    cloudflare-warp.enable = true;
  };
  # Uncomment this if there are weird dns issues when 
  # networking.nameservers = [ "1.1.1.1" ];
  # this make the warp vpn happy and actually connect
  services.resolved.extraConfig = "ResolveUnicastSingleLabel=yes";

  # Misc
  environment.systemPackages = with pkgs; [ slack ];
  boot.initrd.luks.devices."luks-57691d44-253b-4274-a395-e1de76de708d".device = "/dev/disk/by-uuid/57691d44-253b-4274-a395-e1de76de708d";

  # Special nix settings for working with Anduril nix stuff
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
    buildMachines = [rootBwsBuildServer];
  };

  # ssh stuff
  programs.ssh.extraConfig = ''
    Host ghe.anduril.dev
      HostName ghe.anduril.dev
      User git
  '';

  home-manager.users."yajj" = {lib, ...}:  {
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
  };

}
