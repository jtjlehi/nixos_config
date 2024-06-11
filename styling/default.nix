{pkgs, ...}: {
  stylix = let
    theme = "darktooth";
  in {
    image = ../photos/blue-mistborn.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
    polarity = "dark";
    fonts = {
      sizes = {
        terminal = 10;
      };
      monospace = {
        package = pkgs.nerdfonts;
        name = "Monoid Nerd Font Mono";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
    targets = {
      nixvim.enable = true;
    };
  };
}
