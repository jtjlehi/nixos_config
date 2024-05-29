{...}: {
  programs.zellij.enable = true;
  home.file = let
    zellij-path = ".config/zellij";
  in {
    "${zellij-path}/layouts/".source = ./layouts;
    "${zellij-path}/config.kdl".source = ./config.kdl;
  };
}
