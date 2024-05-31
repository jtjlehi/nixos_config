{...}: {
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
}
