{
  config,
  pkgs,
  apple-silicon,
  ...
}: {
  imports  = [hardware/pewter.nix];
  boot.initrd.luks.devices."luks-4e1d1440-cfed-46ef-830d-014473028fd6".device = "/dev/disk/by-uuid/4e1d1440-cfed-46ef-830d-014473028fd6";
  services.timesyncd.extraConfig = ''
    FallbackNTP=10.66.87.1
  '';
  networking.hostName = "pewtermind";
  environment.systemPackages = with pkgs; [
    mattermost-desktop
    matterhorn
  ];
}