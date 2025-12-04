{
  pkgs,
  options,
  lib,
  config,
  ...
}: {
  imports = [
    ./packages
    ./styling
  ];
  nix.settings.experimental-features = ["nix-command" "flakes" "fetch-closure"];
  nix.settings.trusted-users = [ "root" config.username ];
  nix.optimise.automatic = true;

  time.timeZone = "America/Denver";

  documentation.man = {
    enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
