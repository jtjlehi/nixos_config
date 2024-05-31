{pkgs, ...}: {
  home.packages = with pkgs; [
    font-awesome
    monoid
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [];
      sansSerif = ["noto-sans"];
      monospace = ["monoid" "font-awesome"];
      emoji = [];
    };
  };
}
