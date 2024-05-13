{pkgs, ...}: {
  imports = [./waybar.nix];
  home.packages = with pkgs; [
    wl-clipboard
  ];
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      input = {
        "*" = {
          xkb_options = "ctrl:swapcaps";
        };
        "type:touchpad" = {
          dwt = "enabled";
          natural_scroll = "disabled";
          click_method = "button_areas";
        };
      };
      output = {
        "*".bg = "${../../photos/mount-timp-wallpaper.jpg} fill";
      };
      bars = [{command = "waybar";}];
    };
  };
}
