{
  pkgs,
  config,
  ...
}: let
  gitBin = "${pkgs.git}/bin/git";
  writeFzfScript = name: choices: cmd:
    pkgs.writeShellScriptBin name ''
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
in {
  programs.bash.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.shellAliases = {
    "la" = "ls -la";
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  home.packages = let
  in [
    (writeFzfGitScript "g-push" {
      branchOpt = "-l";
      sedPat = "s/^..//";
      gitCmd = "push origin";
    })
    (pkgs.writeShellScriptBin "pull-build" ''
      cd ${config.home.homeDirectory}/.dotfiles/nixos
      OUT=$(${g-pull}/bin/g-pull)
      echo $OUT
      if [[ $OUT == *"Already up to date."* ]];
      then
        echo "Nothing to do"
      else
        sudo nixos-rebuild switch --flake .
      fi
    '')
  ];
}
