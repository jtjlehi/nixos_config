{pkgs, ...}: {
  imports = [hardware/iron.nix];
  anduril-security = {
    kolide-launcher.enable = true;
    cloudflare-warp.enable = true;
  };
  environment.systemPackages = with pkgs; [
    slack
  ];
}
