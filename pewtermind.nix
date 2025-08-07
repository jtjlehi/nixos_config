{pkgs, lib, ...}: {
  imports = [hardware/pewter.nix];
  boot.initrd.luks.devices."luks-4e1d1440-cfed-46ef-830d-014473028fd6".device = "/dev/disk/by-uuid/4e1d1440-cfed-46ef-830d-014473028fd6";
  services.timesyncd.extraConfig = ''
    FallbackNTP=10.66.87.1
  '';
  environment.systemPackages = with pkgs; [
    mattermost-desktop
  ];
  fileSystems."/home/yajj/bws/fileshare" = {
    device = "nfs.bws.sys:/data";
    fsType = "nfs";
  };
  home-manager.users."yajj" = {config, lib, ...}:  {
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      ironmind = {
        hostname = "192.168.70.95";
        user = "yajj";
      };
    };
    programs.git.userEmail = lib.mkForce "jjacobson@blackwiresig.com";
  };
}
