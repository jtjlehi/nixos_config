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
    sway-contrib.grimshot
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
  programs.swaylock.enable = true;

  scripts = [
    {
      name = "edit-config";
      runtimeInputs = with pkgs; [zellij];
      text = "zellij --layout nixos-config";
    }
    {
      name = "clamMode";
      runtimeInputs = with pkgs; [sway jq];
      text = ''
        enabled=$(swaymsg -t get_outputs | jq '.[] | select(.name == "eDP-1") | .active')
        if [[ $enabled == "true" ]]; then
            swaymsg 'output eDP-1 disable'
        else
            swaymsg 'output eDP-1 enable'
        fi
      '';
    }
    {
      name = "swapAltWin";
      runtimeInputs = with pkgs; [sway];
      text = ''
        swaymsg 'input * xkb_options "altwin:swap_lalt_lwin,ctrl:swapcaps"'
      '';
    }
  ];
  programs.alacritty.enable = true;
  wayland.windowManager.sway = let
    inherit (builtins) listToAttrs attrNames;
    cfg = config.wayland.windowManager.sway.config;
    tofi-exec = exec: ''${pkgs.tofi}/bin/tofi-run | xargs swaymsg exec ${exec} --'';
    bind-execs = bindings:
      listToAttrs (map (name: {
          name = "${cfg.modifier}+${name}";
          value = "exec ${bindings.${name}}";
        })
        (attrNames bindings));
    useScript = s: "${config.scriptApps.${s}}/bin/${s}";
  in {
    enable = true;
    extraConfig = builtins.readFile ./sway;
    systemd.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = tofi-exec "";
      keybindings = lib.mkOptionDefault (bind-execs {
        o = "${pkgs.wlogout}/bin/wlogout";
        "Shift+Return" = tofi-exec cfg.terminal;
        c = "${cfg.terminal} -e edit-config";
        t = useScript "clamMode";
        "Shift+s" = useScript "swapAltWin";
        p = "grimshot copy area";
      });
      output."DP-1" = {
        scale = "1";
        mode = "3440x1440@98.841hz";
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
