{
  config,
  lib,
  mkSharedDir,
  ...
}: {
  virtualisation.vmVariant.virtualisation = {
    sharedDirectories = {
      bws = mkSharedDir config "bws";
    };
    # hardware
    memorySize = 1024 * 16;
    cores = 11;
    resolution = {
      x = 3440;
      y = 1440;
    };
    # extra opts
    qemu.options = ["-vga std" "-display gtk,grab-on-hover=on"];
  };
  systemd.tmpfiles.settings."10-qemu-vm" = {
    "${config.users.users.yajj.home}/.dotfiles/nixos".Z = {
      user = "yajj";
      group = "users";
    };
    "${config.users.users.yajj.home}/bws".Z = {
      user = "yajj";
      group = "users";
    };
  };
  # for some reason the vm fails to build if we use the cache
  documentation.man.generateCaches = lib.mkForce false;
}
