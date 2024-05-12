{
  config,
  pkgs,
  apple-silicon,
  ...
}: {
  home.packages = with pkgs; [
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [];
      sansSerif = [];
      monospace = [];
      emoji = [];
    };
  };
}
