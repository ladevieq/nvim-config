require('plugins')
require('global-options')
require('mappings')
require('colorscheme')

local api = vim.api

-- ----------------------------------
--           Nvim LSP client
-- ----------------------------------
local CursorHoldGroup = api.nvim_create_augroup("LSP", { clear = true })
api.nvim_create_autocmd("CursorHold", { command = "lua vim.diagnostic.open_float()", group = CursorHoldGroup, pattern = { "*" }})

api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end

        if client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

        buffer_lsp_mappings(client, ev.buf)

        -- if client.server_capabilities.document_formatting then
        --     local LSPFormattingGroup = api.nvim_create_augroup("LSPFormatting", {})
        --     api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()", group = LSPFormattingGroup, pattern = { "<buffer>" }})
        -- end

        if client.server_capabilities.documentHighlightProvider then
            local DocumentHighlightGroup = api.nvim_create_augroup("LSPDocumentHighlight", { clear = true })
            api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { command = "lua vim.lsp.buf.document_highlight()", group = DocumentHighlightGroup, pattern = { "<buffer>" }})
            api.nvim_create_autocmd("CursorMoved", { command = "lua vim.lsp.buf.clear_references()", group = DocumentHighlightGroup, pattern = { "<buffer>" }})
        end
    end,
})

vim.lsp.config.clangd = {
    cmd = { 'clangd', '--background-index', '--completion-style=detailed' },
    root_markers = { '.git', 'compile_flags.txt', 'compile_commands.json' },
    filetypes = { 'c', 'cpp' }
}
vim.lsp.enable('clangd')

vim.diagnostic.config {
    update_in_insert = true,
    float = {
        focusable = false,
    },
    virtual_text = {
        current_line = true
    },
}

-- ----------------------------------
--           Treesitter
-- ----------------------------------
require'nvim-treesitter.configs'.setup {
    ensure_installed = { "lua", "c", "cpp", "hlsl" },
    highlight = {
        enable = true,              -- false will disable the whole extension
    },
    indent = {
        enable = true,
    },
}

require('nvim-autopairs').setup({
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
        local npairs = require("nvim-autopairs")
        local rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")

        npairs.setup(opts)

        local is_template = require("util.pair").is_template
        local semicolon = require("util.pair").struct_class_semicolon

        npairs.add_rules({
            rule("<", ">"):with_pair(cond.none()):with_move(cond.done()):use_key(">"),
            rule("{", "};", { "cpp", "c" }):with_pair(semicolon),
        })

        vim.keymap.set("i", "<", is_template)
    end,
})

-- ----------------------------------
--           fzf-lua
-- ----------------------------------
require 'fzf-lua'.setup {
    files = {
        fd_opts           = [[--color=never --type f --hidden --follow -E .git -E .cache -E .vs -E Intermediate]]
    },
    grep = {
        rg_glob = true
    }
}
