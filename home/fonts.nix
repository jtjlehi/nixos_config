{
  config,
  pkgs,
  apple-silicon,
  ...
}: {
  home.packages = with pkgs; [
    font-awesome
    monoid
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [];
      sansSerif = [];
      monospace = ["monoid" "font-awesome"];
      emoji = [];
    };
  };
}
