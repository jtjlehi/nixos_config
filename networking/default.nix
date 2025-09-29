{ lib, config, pkgs, ... }:
let
  wg-bws-cfg = config.networking.wg-bws;
in {
  imports = [];

  options.networking.wg-bws = {
    enable = lib.mkEnableOption "BWS wireguard";
    
  };

  config = {
    # basic networking config
    systemd.network.enable = true;
    networking.wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
    networking.useNetworkd = true;
  };
}
