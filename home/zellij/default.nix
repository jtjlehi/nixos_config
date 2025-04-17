{
  pkgs,
  config,
  ...
}: let
  kdl = _args: _props: children: children // {inherit _props _args;};
  wasmTarget = "wasm32-unknown-unknown";
  inputs = with pkgs; [
    (rust-bin.stable.latest.default.override {
      targets = [wasmTarget];
    })
    wasm-pack
    wasm-bindgen-cli
  ];

  mkRustWasm = {
    name,
    src,
    cargoHash,
    nativeBuildInputs ? [],
  }:
    pkgs.rustPlatform.buildRustPackage {
      inherit name src cargoHash;

      nativeBuildInputs = inputs ++ nativeBuildInputs;

      doCheck = false;
      dontCargoInstall = true;

      buildPhase = ''
        cargo build --release --target=${wasmTarget}

        echo "Creating out dir"
        mkdir -p $out/src;

        cp target/${wasmTarget}/release/${name}.wasm $out/src;
      '';
    };

in
  with config.lib.stylix.colors.withHashtag; {
    programs.zellij.enable = true;
    programs.zellij.settings = {
      plugins = {
        tab-bar = kdl [] {location = "zellij:tab-bar";} {};
        status-bar = kdl [] {location = "zellij:status-bar";} {};
        strider = kdl [] {location = "zellij:strider";} {};
        compact-bar = kdl [] {location = "zellij:compact-bar";} {};
        session-manager = kdl [] {location = "zellij:session-manager";} {};
        welcome-screen = kdl [] {location = "zellij:session-manager";} {
          welcome_screen = true;
        };
        filepicker = kdl [] {location = "zellij:strider";} {
          cwd = "/";
        };
      };
      on_force_close = "detach";
      no_pane_frames = true;
    };
    xdg.configFile."zellij/layouts/default.kdl".text =
      /*
      kdl
      */
      ''
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

                        // hide_frame_for_single_pane true
                        // no_pane_frames true

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
            }
        }
      '';
    xdg.configFile."zellij/layouts/rust.kdl".source = ./layouts/rust.kdl;
    xdg.configFile."zellij/layouts/nixos-config.kdl".source = ./layouts/nixos-config.kdl;

    scripts = [
      {
        name = "clippy-filter";
        # use the version of cargo and clippy that the project uses
        runtimeInputs = [pkgs.jq];
        text = /* bash */ ''
            cargo clippy --message-format json-diagnostic-rendered-ansi -- -W clippy::pedantic | jq "
                select(. | type == \"object\")
                | select(has(\"message\"))
                | select([.message.spans[] | .file_name | contains(\"$1\")] | any)
                | .message.rendered
                " --raw-output
          '';
      }
    ];

    programs.bacon = {
      enable = true;
    };
    xdg.configFile."zellij/config.kdl".text = let
      inherit (builtins) genList toString concatStringsSep;
      bindTo = {
        mkKey,
        mkAction,
      }:
        concatStringsSep "\n" (genList
          (k: let
            key = toString (k + 1);
          in ''bind ${mkKey key} { ${mkAction key}; }'')
          9);
      altTabBinds = bindTo {
        mkKey = k: ''"Alt ${k}"'';
        mkAction = k: "GoToTab ${k}";
      };
      tabBinds = bindTo {
        mkKey = k: ''"${k}"'';
        mkAction = k: "GoToTab ${k}; SwitchToMode \"Normal\"";
      };
    in
      /*
      kdl
      */
      ''
        pane_frames false
        keybinds clear-defaults=true {
            shared_except "locked" {
                bind "Alt h" "Alt Left" { MoveFocus "Left"; }
                bind "Alt l" "Alt Right" { MoveFocus "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }
                bind "Alt =" "Alt +" { Resize "Increase"; }
                bind "Alt -" { Resize "Decrease"; }
                bind "Alt [" { PreviousSwapLayout; }
                bind "Alt ]" { NextSwapLayout; }
                ${altTabBinds}
                bind "Ctrl b" { SwitchToMode "Tmux"; }

            }
            shared_except "locked" "normal" {
                bind "Enter" "Esc" { SwitchToMode "Normal"; }
            }
            // these aren't really tmux bindinds, there just my bindings
            tmux {
                bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
                // switch to other modes
                bind "p" { SwitchToMode "Pane"; }
                bind "t" { SwitchToMode "Tab"; }
                bind "r" { SwitchToMode "Resize"; }
                bind "m" { SwitchToMode "Move"; }
                bind "/" { SwitchToMode "Search"; }
                bind "s" { SwitchToMode "Session"; }
                bind "n" { GoToNextTab; SwitchToMode "Normal"; }
                bind "S" { SwitchToMode "Scroll"; }
                // panes
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                bind "n" { NewPane; SwitchToMode "Normal"; }
                // move
                bind "Left" "h" { MoveFocusOrTab "Left"; }
                bind "Right" "l" { MoveFocusOrTab "Right"; }
                bind "Down" "j" { MoveFocus "Down"; }
                bind "Up" "k" { MoveFocus "Up"; }
                // actions
                bind "q" { Detach; }
                bind "?" {
                    Run "zellij" "run" "--height=80%" "-x=10%" "-f" "--width=80%" "-c" "-y=10%" "--" "fman";
                    SwitchToMode "Normal";
                }
                // other
                bind "Space" { NextSwapLayout; }
            }
            shared_among "tab" "tmux" {
                ${tabBinds}
                bind "Tab" { ToggleTab; }
            }
            locked {
                bind "Ctrl g" { SwitchToMode "Normal"; }
            }
            resize {
                bind "Ctrl n" { SwitchToMode "Normal"; }
                bind "h" "Left" { Resize "Increase Left"; }
                bind "j" "Down" { Resize "Increase Down"; }
                bind "k" "Up" { Resize "Increase Up"; }
                bind "l" "Right" { Resize "Increase Right"; }
                bind "H" { Resize "Decrease Left"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
                bind "L" { Resize "Decrease Right"; }
                bind "=" "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
                bind "m" { SwitchToMode "Move"; }
            }
            pane {
                bind "Ctrl p" { SwitchToMode "Normal"; }
                bind "h" "Left" { MoveFocus "Left"; }
                bind "l" "Right" { MoveFocus "Right"; }
                bind "j" "Down" { MoveFocus "Down"; }
                bind "k" "Up" { MoveFocus "Up"; }
                bind "p" { SwitchFocus; }
                bind "n" { NewPane; SwitchToMode "Normal"; }
                bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0;}
            }
            move {
                bind "Ctrl h" { SwitchToMode "Normal"; }
                bind "n" "Tab" { MovePane; }
                bind "p" { MovePaneBackwards; }
                bind "h" "Left" { MovePane "Left"; }
                bind "j" "Down" { MovePane "Down"; }
                bind "k" "Up" { MovePane "Up"; }
                bind "l" "Right" { MovePane "Right"; }
                bind "r" { SwitchToMode "Resize"; }
            }
            tab {
                bind "Ctrl t" { SwitchToMode "Normal"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "h" "Left" "Up" "k" { GoToPreviousTab; }
                bind "l" "Right" "Down" "j" { GoToNextTab; }
                bind "H" { MoveTab "Left"; }
                bind "L" { MoveTab "Right"; }
                bind "n" { NewTab; SwitchToMode "Normal"; }
                bind "x" { CloseTab; SwitchToMode "Normal"; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                bind "b" { BreakPane; SwitchToMode "Normal"; }
                bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
            }
            scroll {
                bind "Ctrl s" { SwitchToMode "Normal"; }
                bind "e" { EditScrollback; SwitchToMode "Normal"; }
                bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                // uncomment this and adjust key if using copy_on_select=false
                // bind "Alt c" { Copy; }
            }
            search {
                bind "Ctrl s" { SwitchToMode "Normal"; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
                bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "n" { Search "down"; }
                bind "p" { Search "up"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "o" { SearchToggleOption "WholeWord"; }
            }
            entersearch {
                bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
                bind "Enter" { SwitchToMode "Search"; }
            }
            session {
                bind "Ctrl o" { SwitchToMode "Normal"; }
                bind "Ctrl s" { SwitchToMode "Scroll"; }
                bind "d" { Detach; }
                bind "w" {
                    LaunchOrFocusPlugin "session-manager" {
                        floating true
                        move_to_focused_tab true
                    };
                    SwitchToMode "Normal"
                }
            }
            // renaming
            renametab {
                bind "Ctrl c" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
            }
            renamepane {
                bind "Ctrl c" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
            }
        }
      '';
  }
