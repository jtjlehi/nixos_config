{pkgs, ...}: {
  home.packages = with pkgs; [
    # language servers
    nil # nix language server
    lua-language-server
    rust-analyzer
    # Formatters
    alejandra # auto-formatter for nix
    rustfmt
    stylua
  ];
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
            dhall
            xml
            vimdoc
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
      nvim-lspconfig
      conform-nvim
      {
        plugin = lsp-zero-nvim;
        type = "lua";
        config = builtins.readFile ./lsp.lua;
      }
      # rust-tools-nvim
      # haskell-tools-nvim
      # completions
      luasnip
      cmp-nvim-lsp
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./cmp.lua;
      }
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
      telescope-live-grep-args-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', 'ff', builtin.find_files)
          vim.keymap.set('n', 'fe', builtin.diagnostics)
          vim.keymap.set('n', 'fg', function()
            require('telescope').extensions.live_grep_args.live_grep_args()
          end)
          vim.keymap.set('n', 'fb', builtin.buffers)
          vim.keymap.set('n', 'f<C-O>', builtin.jumplist)
          vim.keymap.set('n', 'fd', builtin.lsp_references)
          vim.keymap.set('n', 'fw', builtin.grep_string)
        '';
      }
    ];
  };
}
