{ pkgs
, lib
, ... 
}: {
  home.packages = [pkgs.helix];
  programs.helix.enable = true;
  programs.helix.settings = {
    theme = lib.mkForce "better_stylix";
    editor = {
      rulers = [80];
      color-modes = true;
      cursor-shape.insert = "bar";
      indent-guides.render = true;
      whitespace.render = "all";
    };
  };
  # with helix's inherits theme thing, it makes it easier to customize the theme
  programs.helix.themes.better_stylix = {
    "inherits" = "stylix";
    "diagnostic.warning" = { underline = { color = "base09"; style = "curl"; }; };
    "diagnostic.deprecated" = { modifiers = ["crossed_out"]; };
  };
}
