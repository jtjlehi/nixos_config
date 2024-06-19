{
  pkgs,
  config,
  ...
}: {
  programs.zellij.enable = true;
  xdg.configFile."zellij/layouts/default.kdl".text = with config.lib.stylix.colors.withHashtag; ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                    format_left   "{mode} #[fg=${base07},bold]{session}"
                    format_center "{tabs}"
                    format_right  "{command_git_branch}"
                    format_space  ""

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=${base0C}]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_default_to_mode    "#[bg=${base0F}]"
                    mode_locked       "#[bg=${base06}] {name} "
                    mode_normal       "#[bg=${base0D}] "
                    mode_tmux         "#[bg=${base0A},fg=${base00}] {name} "
                    mode_resize       "#[bg=${base09},fg=${base00}] {name} "
                    mode_move         "#[bg=${base09},fg=${base00}] {name} "
                    mode_pane         "#[bg=${base0B},fg=${base00}] {name} "
                    mode_tab          "#[bg=${base0B},fg=${base00}] {name} "
                    mode_scroll       "#[bg=${base0A},fg=${base00}] {name} "
                    mode_enter_search "#[bg=${base0A},fg=${base00}] {name} "
                    mode_search       "#[bg=${base0A},fg=${base00}] {name} "
                    mode_rename_tab   "#[bg=${base0F},fg=${base00}] {name} "
                    mode_rename_pane  "#[bg=${base0F},fg=${base00}] {name} "
                    mode_session      "#[bg=${base0B},fg=${base00}] {name} "
                    mode_prompt       "#[bg=${base08},fg=${base00}] {name} "

                    tab_normal   "#[bg=${base02},fg=${base06}] {name} "
                    tab_active   "#[bg=${base06},fg=${base02},bold,italic] {name} "

                    command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                    command_git_branch_format      "#[bg=${base0D},fg=${base00}] {stdout} "
                    command_git_branch_interval    "10"
                    command_git_branch_rendermode  "static"
                }
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
    }
  '';
  xdg.configFile."zellij/layouts/rust.kdl".source = ./layouts/rust.kdl;
  xdg.configFile."zellij/layouts/nixos-config.kdl".source = ./layouts/nixos-config.kdl;
  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
}
