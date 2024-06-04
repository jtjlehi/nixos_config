-- define the lsp capabilities to use
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local bufnr = event.buf
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end
        local lsp_buf = vim.lsp.buf

        -- bindings

        map('K', lsp_buf.hover, 'Hover Documentation')
        map('<leader>r', lsp_buf.rename, '[r]ename')
        map('<leader>ca', lsp_buf.code_action, '[C]ode [A]ction')
        map('gd', lsp_buf.declaration, '[G]oto [D]ecleration')


        -- capabilities

        local ifCapable = function(capability, f)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.server_capabilities[capability] then
                f()
            end
        end

        ifCapable("documentHighlightProvider", function()
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
                end,
            })
          end)
    end,
})

local lspconfig = require('lspconfig')

lspconfig.rust_analyzer.setup({
    tools = {
        inlay_hints = { only_current_line = true }
    },
    server = {
        on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
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

