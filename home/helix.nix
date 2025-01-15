{ pkgs
, lib
, ...
}: {
  home.packages = with pkgs; [
    helix
    clang-tools # for clangd
  ];
  programs.helix.enable = true;
  programs.helix.defaultEditor = true;
  programs.helix.languages = {
    language = [
      {
        name = "haskell";
        formatter = { command = "fourmolu"; args = ["--stdin-input-file" "."]; };
        auto-format = true;
      }
    ];
    language-server = {
      haskell-language-server = {
        command = "haskell-language-server";
        args = ["--lsp"];
      };
      rust-analyzer.config = {
        check.command = "clippy";
      };
    };
  };
  programs.helix.settings = {
    # the stylix generated theme is terrible
    theme = lib.mkForce "flexoki_dark";
    editor = {
      rulers = [80];
      color-modes = true;
      cursor-shape.insert = "bar";
      indent-guides.render = true;
      whitespace.render = "all";
      soft-wrap.enable = true;
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
