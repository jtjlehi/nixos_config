{pkgs, ...}: {
  stylix = {
    # image = ../photos/mount-timp-wallpaper.jpg;
    image = ../photos/blue-mistborn.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/darktooth.yaml";
    polarity = "dark";
    fonts = {
      sizes = {
        terminal = 9;
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
