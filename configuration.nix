{
  pkgs,
  options,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  # networking.networkmanager.enable = true;
  networking.timeServers = options.networking.timeServers.default;
  systemd.network.enable = true;
  networking.useNetworkd = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone.
  time.timeZone = "America/Denver";
  services.timesyncd.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yajj = {
    isNormalUser = true;
    extraGroups = ["wheel" "network"];
    hashedPassword = "$6$11223344$d3FPnBQ56DuWIYjVYfYxOiemLqPobvGAdfft6CBoDQ.i83av5TaQyr.ad6HyVnvPizZVzW2uuj6jVQLPYHaLC1";
  };
  security.sudo.configFile = ''
    Defaults !env_reset
  '';
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];

  environment.systemPackages = with pkgs; [
    git
    gh
    ripgrep
    nushell
    zsh
    neovim
    pulseaudio
  ];
  documentation.man = {
    enable = true;
    generateCaches = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
