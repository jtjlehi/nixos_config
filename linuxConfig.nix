{
  pkgs,
  options,
  lib,
  ...
}: {
  imports = [./styling ./networking];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone.
  services.timesyncd.enable = lib.mkForce true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  security.polkit.enable = true;
  programs.sway.enable = true;
  xdg.portal.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.mutableUsers = false;
  users.users.yajj = {
    isNormalUser = true;
    extraGroups = ["wheel" "network"];
    hashedPassword = "$6$11223344$d3FPnBQ56DuWIYjVYfYxOiemLqPobvGAdfft6CBoDQ.i83av5TaQyr.ad6HyVnvPizZVzW2uuj6jVQLPYHaLC1";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  hardware.graphics.enable = true;

  # podman/docker
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
