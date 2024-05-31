{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./init.lua;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-treesitter.withPlugins (p:
          with p; [
            bash
            rust
            lua
            haskell
            nix
          ]);
        type = "lua";
        config = ''
          require "nvim-treesitter.configs".setup {
              highlight = { enable = true },
              incremental_selection = { enable = true },
              indent = { enable = true }
          }
        '';
      }
      # colorscheme
      gruvbox-nvim
      # appearance
      nvim-web-devicons
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require "lualine".setup {
              options = {
                  theme = "auto",
              },
              sections = {
                  lualine_c = {},
                  lualine_x = { 'filetype' },
                  lualine_y = {},
              },
              winbar = {
                  lualine_a = { { 'filename', path = 1 } },
                  lualine_z = { 'location' },
              },
              inactive_winbar = {
                  lualine_a = { { 'filename', path = 1 } },
                  lualine_z = { 'location' },
              },
          }
        '';
      }
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
      rust-tools-nvim
      haskell-tools-nvim
      # folding
      {
        plugin = nvim-ufo;
        type = "lua";
        config = ''
          local ufo = require('ufo')
          vim.keymap.set('n', 'zR', ufo.openAllFolds)
          vim.keymap.set('n', 'zM', ufo.closeAllFolds)

          ufo.setup()
        '';
      }
      # auto completions
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup({
            check_ts = true;
          })
        '';
      }
      {
        plugin = comment-nvim;
        type = "lua";
        config = "require('Comment').setup()";
      }
      telescope-nvim
    ];
  };
}
