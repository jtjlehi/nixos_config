{pkgs, ...}: {
  home.packages = [pkgs.waybar];
  home.file.".config/waybar/style.css".source = ./waybar.css;
  programs.waybar = let
    inherit (builtins) catAttrs;
    left = [
      {
        name = "sway/workspaces";
        config = {disable-scroll = true;};
      }
      {name = "sway/scratchpad";}
      {name = "sway/window";}
    ];
    center = [
      {
        name = "sway/mode";
        config = {format = "<span style=\"italic\">{}</span>";};
      }
    ];
    right = [
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
  };
}
