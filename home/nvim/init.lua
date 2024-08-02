--[[ init.lua ]]
-- LEADER
-- These keybindings need to be defined before the first /
-- is called; otherwise, it will default to "\"
vim.g.mapleader = ","
vim.g.localleader = "\\"

local L = [[<Leader>]]

-------------------------------------------------------------------------------
-- INSERT MODE
-------------------------------------------------------------------------------

-- remap the key used to leave insert mode
vim.keymap.set("i", "jj", "<Esc>")
-- insert λ
vim.keymap.set("i", "<C-l>", "<C-v>u03bb")
-- digraphs (used in insert mode by <C-k>)
local dig = function(char, number)
	vim.cmd("digr " .. char .. " " .. number)
end
dig("gr", 0x03c1) -- rho (ρ)
dig("gs", 0x03c3) -- sigma (σ)
dig("gS", 0x03a3) -- Sigma (Σ)
dig("gz", 0x03b6) -- zeta (ζ)
dig("gG", 0x0393) -- Gamma (Γ)

-------------------------------------------------------------------------------
-- NORMAL MODE
-------------------------------------------------------------------------------

-- Clear Search
vim.keymap.set("n", L .. "cs", function()
	vim.cmd("nohlsearch")
end)
-- Show Errors
vim.keymap.set("n", L .. "e", vim.diagnostic.open_float)
vim.keymap.set("n", L .. "ge", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", L .. "gE", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
-------------------------------------------------------------------------------
-- NORMAL MODE
-------------------------------------------------------------------------------
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]])
vim.keymap.set("t", "jj", [[<C-\><C-n>]])

--[[ options ]]
-- [[ Context ]]
vim.o.colorcolumn = "80" -- str:  Show col for max line length
vim.o.number = true -- bool: Show line numbers
vim.o.relativenumber = true -- bool: Show relative line numbers
vim.o.scrolloff = 1 -- int:  Min num lines of context
vim.o.signcolumn = "yes" -- str:  Show the sign column

-- [[ Spellchecker ]]
vim.o.spell = true
vim.o.spelllang = "en"
vim.o.spelloptions = "camel"

-- [[ Filetypes ]]
vim.o.encoding = "utf8" -- str:  String encoding to use
vim.o.fileencoding = "utf8" -- str:  File encoding to use

-- [[ Theme ]]
vim.o.termguicolors = true -- bool: If term supports ui color then enable

-- [[ Search ]]
vim.o.ignorecase = true -- bool: Ignore case in search patterns
vim.o.smartcase = true -- bool: Override ignorecase if search contains capitals
vim.o.incsearch = true -- bool: Use incremental search

-- [[ Whitespace ]]
vim.o.expandtab = true -- bool: Use spaces instead of tabs
vim.o.shiftwidth = 4 -- num:  Size of an indent
vim.o.softtabstop = 4 -- num:  Number of spaces tabs count for in insert mode
vim.o.tabstop = 4 -- num:  Number of spaces tabs count for
vim.o.list = true
vim.opt.listchars:append("tab:<->")
vim.opt.listchars:append("lead:•")

-- [[ Splits ]]
vim.o.splitright = true -- bool: Place new window to right of current one
vim.o.splitbelow = true -- bool: Place new window below the current one

-- [[ Folding ]]
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Update packpath
-- local packer_path = vim.fn.stdpath('config') .. '/site'
-- vim.o.packpath = vim.o.packpath .. ',' .. packer_path

-------------------------------------------------------------------------------
-- PLUGINS
-------------------------------------------------------------------------------
-- require "plug"
-- require "nvim-tree".setup()
-- require "lualine".setup {
--     options = {
--         theme = "auto",
--     },
--     sections = {
--         lualine_c = {},
--         lualine_x = { 'filetype' },
--         lualine_y = {},
--     },
--     winbar = {
--         lualine_a = { { 'filename', path = 1 } },
--         lualine_z = { 'location' },
--     },
--     inactive_winbar = {
--         lualine_a = { { 'filename', path = 1 } },
--         lualine_z = { 'location' },
--     },
-- }
-- Treesitter
-- require "nvim-treesitter.configs".setup {
--     auto_install = true,
--     highlight = { enable = true },
--     incremental_selection = { enable = true },
--     indent = { enable = true }
-- }
-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
-- parser_config.kxi = {
--     install_info = {
--         url = "~/Projects/tree-sitter-kxi", -- local path or git repo
--         files = { "src/parser.c" },         -- note that some parsers also require src/scanner.c or src/scanner.cc
--     },
--     filetype = "kxi",                       -- if filetype does not match the parser name
-- }

-- auto close
-- local npairs = require "nvim-autopairs"

-- npairs.setup {
--     check_ts = true,
-- }

-- require "lsp" -- imported from local config file
-- require "ibl".setup {}
-- require "Comment".setup()

-------------------------------------------------------------------------------
-- IMPORTS
-------------------------------------------------------------------------------

-- require "cmds" -- Cmd
-- require "opts" -- Options
-- require "keys" -- Keymaps
