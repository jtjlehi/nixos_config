{ config, pkgs, inputs, ... }:

{
  imports = [ ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yajj";
  home.homeDirectory = "/home/yajj";

  # sway
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
      bars = [
        { command = "waybar"; }
      ];
    };
  };
  # waybar
  programs.waybar = let
    inherit (builtins) catAttrs;
    left = [
      {
        name = "sway/workspaces";
        config = { disable-scroll = true; };
      }
      { name = "sway/scratchpad"; }
      { name = "sway/window"; }
    ];
    center = [ 
      {
        name = "sway/mode";
        config = { format = "<span style=\"italic\">{}</span>"; };
      }
    ];
    right = [
      {
        name = "idle_inhibitor";
        # config = {
        #   format = "{icon}";
        #   format-icons = {
        #     activated = "";
        #     deactivated = "";
        #   };
        # };
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
        config = {
          #  "scroll-step": 1, // %, can be a float
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          # on-click = "amixer set Master toggle";
          # on-click-right = "pavucontrol";
        };
      }
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
        config = { spacing = 10; };
      }
    ];
    init = {
      layer = "top";
      height = 30;
      modules-left = catAttrs "name" left;
      modules-center = catAttrs "name" center;
      modules-right = catAttrs "name" right;
    };
  in {
    enable = true;
    settings = [
      (builtins.foldl'
        (acc: attrs:
          if attrs ? "config"
          then acc // { ${attrs.name} = attrs.config; }
          else acc)
        init
        (left ++ center ++ right))
    ];
  };

  # git
  programs.git = {
    enable = true;
    userName = "jtjlehi";
    userEmail = "jtjlehi@gmail.com";
  };
  programs.gh.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; let 
    compilers = [ zig ];
    lang-servers = [ lua-language-server nil ];
  in [
    firefox
    neovim
    waybar
    wl-clipboard
  ] ++ compilers ++ lang-servers;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yajj/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
