{
  pkgs,
  config,
  lib,
  ...
}: {
  options = with lib;
  with types; {
    scripts = mkOption {
      description = "a list of all the script binary packages you use";
      type = listOf (submodule {
        options.name = mkOption {
          description = "the name of the script";
          type = str;
        };
        options.text = mkOption {
          description = "the actual content of the shell you're writing";
          type = str;
        };
        options.runtimeInputs = mkOption {
          description = "a list of any extra packages used by the script";
          type = listOf package;
          default = [];
        };
      });
    };
    scriptApps = mkOption {
      type = attrsOf package;
      description = "a list of all the actual binary applications";
    };
  };
  config = {
    programs.bash.enable = true;
    scriptApps = lib.mkForce (
      builtins.listToAttrs (map ({name, ...} @ app: {
          inherit name;
          value = pkgs.writeShellApplication app;
        })
        config.scripts)
    );

    scripts = [
      {
        name = "pull-build";
        runtimeInputs = [config.scriptApps.g-pull];
        text = ''
          cd ${config.home.homeDirectory}/.dotfiles/nixos
          OUT=$(g-pull)
          echo "$OUT"
          if [[ "$OUT" == *"Already up to date."* ]]; then
            echo "Nothing to do"
          else
            sudo nixos-rebuild switch --flake .
          fi
        '';
      }
      {
        name = "g-pull";
        text = ''
          git branch -r |
            sed -r 's/\s*origin\/((\w[^\s])*).*/\1/' |
            fzf |
            xargs git pull origin
        '';
      }
      {
        name = "g-push";
        text = ''git branch -l | sed -r "s/^..//" | fzf | xargs git push origin'';
      }
      {
        name = "fman";
        runtimeInputs = with pkgs; [ripgrep fzf];
        text = ''
          if man "$@" 2> /dev/null; then
            exit 0
          fi
          fullPages=$(man -k .)
          for filter; do
            fullPages=$(echo "$fullPages" | rg "$filter")
          done
          names=$(echo "$fullPages" | sd "(\S*).*" "\$1")
          choice=$(echo "$names" | uniq | fzf)
          pageNumber=$(echo "$fullPages" |
            rg "^$choice\s" |
            sd ".*\((\d*)\).*" "\$1" |
            fzf -1)
          man "$pageNumber" "$choice"
        '';
      }
    ];
    home.sessionVariables = {
      EDITOR = "hx";
      MLM_LICENSE_FILE = "27005@10.32.4.5";
    };
    home.shellAliases = {
      "la" = "ls -la";
      # as far as I can tell using this alias allows me to use tab completion from man as well
      "man" = "fman";
    };
    home.sessionPath = ["$HOME/.cargo/bin"];
    programs.mcfly.enable = true;
    programs.mcfly.fzf.enable = true;
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {};
    };
    programs.zoxide.enable = true;
    home.packages = with pkgs;
      [
        fzf
        ripgrep
        sd
        fd
        difftastic
      ]
      ++ builtins.attrValues config.scriptApps;
  };
}
