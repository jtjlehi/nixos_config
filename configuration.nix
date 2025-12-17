{
  pkgs,
  options,
  lib,
  config,
  ...
}:
{
  imports = [
    ./packages
    ./styling # TODO: maybe move this into the `hm-modules` in `flake.nix`?
  ];
  options = {
    username = lib.mkOption {
      default = "yajj";
      description = "The username to use across the system";
      type = lib.types.str;
    };
    name = lib.mkOption {
      description = "the name of the machine";
      type = lib.types.str;
    };
  };
  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
      "fetch-closure"
    ];
    nix.settings.trusted-users = [
      "root"
      config.username
    ];
    nix.optimise.automatic = lib.mkIf config.nix.enable true;

    time.timeZone = lib.mkDefault "America/Denver";

    documentation.man.enable = lib.mkDefault true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = lib.mkDefault true;
  };
}
