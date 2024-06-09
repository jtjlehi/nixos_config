{
  pkgs,
  lib,
  config,
  ...
}: let
  lock-cmd = "${pkgs.swaylock}/bin/swaylock -f";
in {
  imports = [./waybar.nix];
  home.packages = with pkgs; [
    wl-clipboard
  ];
  programs.wofi = {
    enable = true;
  };
  programs.tofi.enable = true;
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = lock-cmd;
        text = "Lock";
        keybind = "l";
        circular = true;
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        keybind = "e";
        circular = true;
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        circular = true;
      }
      {
        label = "suspend";
        action = "${lock-cmd} && systemctl suspend";
        text = "Suspend";
        keybind = "s";
        circular = true;
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
        circular = true;
      }
    ];
  };
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = lock-cmd;
      }
      {
        timeout = 900;
        command = "systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = lock-cmd;
      }
      {
        event = "after-resume";
        command = "${pkgs.sway}/bin/swaymsg \"output * power on\"";
      }
    ];
  };
  wayland.windowManager.sway = {
    enable = true;
    extraConfig = builtins.readFile ./sway;
    systemd.enable = true;
    config = {
      modifier = "Mod4";
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "${modifier}+o" = "exec ${pkgs.wlogout}/bin/wlogout";
        };
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
      bars = [{command = "waybar";}];
      window = {
        hideEdgeBorders = "smart";
        border = 3;
        titlebar = false;
      };
    };
  };
}
