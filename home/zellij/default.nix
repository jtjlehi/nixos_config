{pkgs, ...}: {
  programs.zellij.enable = true;
  # home.file = let
  #   zellij-path = ".config/zellij";
  # in {
  #   # "${zellij-path}/layouts/".source = ./layouts;
  #   # "${zellij-path}/config.kdl".source = ./config.kdl;
  # };
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                    format_left   "{mode} #[fg=#89B4FA,bold]{session}"
                    format_center "{tabs}"
                    format_right  "{command_git_branch}"
                    format_space  ""

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=#6C7086]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_normal  "#[bg=blue] "
                    mode_tmux    "#[bg=#ffc387] "

                    tab_normal   "#[fg=#6C7086] {name} "
                    tab_active   "#[fg=#9399B2,bold,italic] {name} "

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[fg=blue] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"

                    // datetime        "#[fg=#6C7086,bold] {format} "
                    // datetime_format "%A, %d %b %Y %H:%M"
                    // datetime_timezone "Europe/Berlin"
                }
            }
        }
    }
  '';
  xdg.configFile."zellij/layouts/rust.kdl".source = ./layouts/rust.kdl;
  xdg.configFile."zellij/layouts/nixos-config.kdl".source = ./layouts/nixos-config.kdl;
  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
}
