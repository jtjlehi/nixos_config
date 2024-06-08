{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (pkgs) writeShellScriptBin;
  inherit (lib.strings) concatMapStringsSep stringLength;
  gitBin = "${pkgs.git}/bin/git";
  writeFzfScript = name: choices: cmd:
    writeShellScriptBin name ''
      CHOICE=$(${choices} | ${pkgs.fzf}/bin/fzf)
      echo ${name} $CHOICE
      ${cmd} $CHOICE
    '';
  writeFzfGitScript = name: {
    branchOpt,
    sedPat ? null,
    gitCmd,
  }: let
    sedCmd =
      if builtins.isNull sedPat
      then ""
      else "| sed -r '${sedPat}'";
  in
    writeFzfScript name "${gitBin} branch ${branchOpt} ${sedCmd}" "${gitBin} ${gitCmd}";
  g-pull = writeFzfGitScript "g-pull" {
    branchOpt = "-r";
    sedPat = ''s/\s*origin\/((\w[^\s])*).*/\1/'';
    gitCmd = "pull origin";
  };

  g-push = writeFzfGitScript "g-push" {
    branchOpt = "-l";
    sedPat = "s/^..//";
    gitCmd = "push origin";
  };
  pull-build = pkgs.writeShellScriptBin "pull-build" ''
    cd ${config.home.homeDirectory}/.dotfiles/nixos
    OUT=$(${g-pull}/bin/g-pull)
    echo $OUT
    if [[ $OUT == *"Already up to date."* ]];
    then
      echo "Nothing to do"
    else
      sudo nixos-rebuild switch --flake .
    fi
  '';
  writeFlagScript = name: {
    subCommands ? [],
    flags ? [],
    body ? "",
  }: let
    parsedFlags =
      concatMapStringsSep "\n" (opts: ''
        ${concatMapStringsSep "|" (opt:
          (
            if stringLength opt == 1
            then "-"
            else "--"
          )
          + opt)
        opts})
        ${builtins.head opts}=$2
        shift;;
      '')
      flags;
    parseSub = concatMapStringsSep "\n" ({subName, ...}: "${subName}) ${subName}=true;;") subCommands;
    handleSub =
      concatMapStringsSep "\n" (
        {
          subName,
          subBody,
        }: ''
          if [[ ''$${subName} ]]; then
            ${subBody}
          fi
        ''
      )
      subCommands;
    script = ''
      while [ $# -gt 0 ]
      do
        case $1 in
        ${parsedFlags}
        ${parseSub}
        esac
        shift
      done
      ${handleSub}
      ${body}
    '';
  in
    pkgs.writeShellScriptBin name script;
  fzf-man = pkgs.writeShellApplication {
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
  };
in {
  programs.bash.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.shellAliases = {
    "la" = "ls -la";
    # as far as I can tell using this alias allows me to use tab completion from man as well
    "man" = "fman";
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  home.packages = with pkgs; [
    # cli tools
    fzf
    ripgrep
    sd
    fd
    # scripts
    pull-build
    g-pull
    g-push
    fzf-man
  ];
}
