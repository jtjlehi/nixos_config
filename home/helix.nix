{ pkgs
, lib
, ...
}: {
  home.packages = [pkgs.helix];
  programs.helix.enable = true;
  programs.helix.settings = {
    # the stylix generated theme is terrible
    theme = lib.mkForce "flexoki_dark";
    editor = {
      rulers = [80];
      color-modes = true;
      cursor-shape.insert = "bar";
      indent-guides.render = true;
      whitespace.render = "all";
    };
    keys.normal = {
      g = {
        S-l = [ "select_mode" "goto_line_end" "normal_mode" ];
        S-s = [ "select_mode" "goto_first_nonwhitespace" "normal_mode" ];
      };
      C-x = "extend_line_above";
    };
    keys.insert = {
      j = { j = "normal_mode"; };
    };
  };
}
