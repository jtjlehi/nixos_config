{...}: {
  programs.bash.enable = true;
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.shellAliases = {
    "la" = "ls -la";
  };
}
