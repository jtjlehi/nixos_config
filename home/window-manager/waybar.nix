{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = [pkgs.waybar];
  programs.waybar = let
    inherit (builtins) catAttrs;
    left = [
      {
        name = "sway/mode";
        config = {format = "<span style=\"italic\">{}</span>";};
      }
      {name = "sway/window";}
    ];
    center = [
      {
        name = "sway/workspaces";
        config = {disable-scroll = true;};
      }
      {name = "sway/scratchpad";}
      {
        name = "idle_inhibitor";
        config = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
      }
    ];
    right = [
      {
        name = "network";
        config = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          # "format-alt" = "{ifname}: {ipaddr}/{cidr}";
          # "on-click" = "foot nmtui";
        };
      }
      {
        name = "cpu";
        config = {
          format = "{usage}% ";
          tooltip = false;
        };
      }
      {
        name = "backlight";
        config = {
          # "device": "acpi_video1",
          format = "{percent}% {icon}";
          format-icons = ["🌑" "🌘" "🌗" "🌖" "🌕"];
        };
      }
      {
        name = "pulseaudio";
      }
      # {
      #   name = "pulseaudio";
      #   config = {
      #     #  "scroll-step": 1, // %, can be a float
      #     # format = "{volume}% {icon} {format_source}";
      #     format = "testing";
      #     # format-bluetooth = "{volume}% {icon} {format_source}";
      #     # format-bluetooth-muted = " {icon} {format_source}";
      #     # format-muted = " {format_source}";
      #     # format-source = "{volume}% ";
      #     # format-source-muted = "";
      #     # format-icons = {
      #     #   headphone = "";
      #     #   hands-free = "";
      #     #   headset = "";
      #     #   phone = "";
      #     #   portable = "";
      #     #   car = "";
      #     #   default = ["" "" ""];
      #     # };
      #     # on-click = "amixer set Master toggle";
      #     # on-click-right = "pavucontrol";
      #   };
      # }
      {
        name = "battery";
        config = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };
      }
      {
        name = "clock";
        config = {
          format = "{:%I:%M %p}";
          format-alt = "{:%m-%d-%Y}";
        };
      }
      {
        name = "tray";
        config = {spacing = 10;};
      }
    ];
    init = {
      layer = "top";
      height = 30;
      modules-left = catAttrs "name" left;
      modules-center = catAttrs "name" center;
      modules-right = catAttrs "name" right;
      reload_style_on_change = true;
    };
  in {
    enable = true;
    settings = [
      (builtins.foldl'
        (acc: attrs:
          if attrs ? "config"
          then acc // {${attrs.name} = attrs.config;}
          else acc)
        init
        (left ++ center ++ right))
    ];
    style = lib.mkAfter ''


      * {
          border-radius: 20px;
      }
      .modules-center,
      .modules-right,
      .modules-left
      {
          margin: 5px 0;
          padding: 0;
          background-color: @base01;
      }
      .modules-left {
          border-radius: 0 20px 20px 0;
          padding: 0 20px;
      }
      .modules-right {
          border-radius: 20px 0 0 20px;
          padding: 0 20px;
      }
      #waybar {
          border-radius: 0;
      }

      window#waybar, tooltip {
          background: alpha(@base00, .5);
          color: @base05;
      }

      window .modules-center #workspaces button {
          background-color: transparent;
          color: @base05;
      }
      .modules-center #workspaces button.focused,
      .modules-center #workspaces button.active {
          background: @base07;
          color: @base00;
      }

      .modules-center #idle_inhibitor {
          background-color: transparent;
      }
      .modules-center #idle_inhibitor.activated {
          background-color: @base0A;
          color: @base00;
      }
      #battery,
      #custom-clipboard,
      #custom-colorpicker,
      #custom-powerDraw,
      #bluetooth,
      #pulseaudio,
      #network,
      #disk,
      #memory,
      #backlight,
      #cpu,
      #temperature,
      #custom-weather,
      #idle_inhibitor,
      #jack,
      #tray,
      #window,
      #workspaces,
      #idle_inhibitor {
          padding: 0 17px 0 10px;
      }
    '';
  };
  stylix.targets.waybar = {
    enable = true;
    enableCenterBackColors = true;
    enableRightBackColors = true;
  };
}
