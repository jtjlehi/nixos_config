{ pkgs, lib, ... }:
{
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    window = lib.optionalAttrs pkgs.stdenv.isDarwin {
      option_as_alt = "both";
    };
  };
}
