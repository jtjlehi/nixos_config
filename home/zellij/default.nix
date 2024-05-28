{
  config,
  pkgs,
  ...
}: {
  programs.zellij.enable = true;
  home.file = {
    "${builtins.getEnv "XDG_CONFIG_DIRS"}/.config/zellij/layouts/".source =
      ./layouts;
  };
}
