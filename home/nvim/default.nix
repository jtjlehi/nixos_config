{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    plugins = with pkgs;
    with vimPlugins; [
      # nvim-web-devicons
      # nvim-tree
      nvim-treesitter
      # appearance
      lualine-nvim
      rainbow-delimiters-nvim
      indent-blankline-nvim
      # git
      vim-fugitive
      vim-gitgutter
      # lsp
      lsp-zero-nvim
      nvim-lspconfig
      cmp-nvim-lsp
      nvim-cmp
      luasnip
      nvim-ufo # folding
      rust-tools-nvim
      haskell-tools-nvim
      # auto completions
      nvim-autopairs
      comment-nvim
      telescope-nvim
    ];
  };
}
