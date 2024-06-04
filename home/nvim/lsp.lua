-- define the lsp capabilities to use
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local bufnr = event.buf
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
		end
		local lsp_buf = vim.lsp.buf

		-- bindings

		map("K", lsp_buf.hover, "Hover Documentation")
		map("<leader>r", lsp_buf.rename, "[r]ename")
		map("<leader>ca", lsp_buf.code_action, "[C]ode [A]ction")
		map("gD", lsp_buf.declaration, "[G]oto [D]ecleration")

		-- telescope
		local telescope = require("telescope.builtin")

		map("gd", telescope.lsp_definitions, "[g]oto [d]efinitions")
		map("fd", telescope.lsp_references, "[f]ind [D]efinitions")
		map("fs", telescope.lsp_document_symbols, "[f]ind [s]ymbols")
		map("ft", telescope.lsp_type_definitions, "[f]ind [t]ype definitions")
		map("fws", telescope.lsp_dynamic_workspace_symbols, "[f]ind [w]orkspace [s]ymbols")

		-- capabilities

		local ifCapable = function(capability, f)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities[capability] then
				f()
			end
		end

		ifCapable("documentHighlightProvider", function()
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", {
				clear = false,
			})
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({
						group = "lsp-highlight",
						buffer = event2.buf,
					})
				end,
			})
		end)
	end,
})

---------------------------------
-- Language Specific LSP Setup --
---------------------------------

local lspconfig = require("lspconfig")

-- lua

lspconfig.lua_ls.setup({
	on_init = function(client)
		local path = client.workspace_folders[1].name
		if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
			return
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					-- Depending on the usage, you might want to add additional paths here.
					-- "${3rd}/luv/library"
					-- "${3rd}/busted/library",
				},
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
				-- library = vim.api.nvim_get_runtime_file("", true)
			},
		})
	end,
	settings = {
		Lua = {},
	},
})

-- rust

lspconfig.rust_analyzer.setup({
	tools = {
		inlay_hints = { only_current_line = true },
	},
	server = {
		on_attach = function(_, bufnr)
			-- Hover actions
			-- vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
			-- Code action groups
			-- vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
		settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
					extraArgs = { "--all", "--", "-D", "clippy::all" },
				},
			},
		},
	},
})

----------------
-- Formatting --
----------------

local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		rust = { "rstfmt" },
		nix = { "alejandra" },
		lua = { "stylua" },
	},
	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 500,
	},
})
