require('plugins')
require('global-options')
require('mappings')

local api = vim.api
local FTDetectGroup = api.nvim_create_augroup("FTDetect", { clear = true })
api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { command = "setfiletype glsl", group = FTDetectGroup, pattern = { "*.fx", "*.hlsl" }}
)

local global = vim.g
global.vscode_style = "dark"

local cmd = vim.cmd
cmd 'colorscheme vscode'

-- ----------------------------------
--           Telescope
-- ----------------------------------

local actions = require('telescope.actions')

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close
            }
        }
    }
}
require('telescope').load_extension 'fzf'

-- ----------------------------------
--           ! Telescope
-- ----------------------------------

-- ----------------------------------
--           Nvim LSP client
-- ----------------------------------

local CursorHoldGroup = api.nvim_create_augroup("LSP", { clear = true })
api.nvim_create_autocmd("CursorHold", { command = "lua vim.diagnostic.open_float()", group = CursorHoldGroup, pattern = { "*" }})

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

function custom_on_attach(client, bufnr)
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Setup mappings only for buffer with a server
    bufferLspMappings(client, bufnr)
if client.resolved_capabilities.document_formatting then
        local LSPFormattingGroup = api.nvim_create_augroup("LSPFormatting", {})
        api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()", group = LSPFormattingGroup, pattern = { "<buffer>" }})
    end
end

local servers = { 'rust_analyzer', 'gopls'}
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = custom_on_attach,
        capabilities = capabilities,
    }
end

-- Disable clangd auto formatting if there is not .clang-format
lspconfig['clangd'].setup {
    on_attach = function(client, bufnr)
        local cwd = vim.fn['getcwd']()
        if lspconfig.util.root_pattern(".clang-format")(cwd) ~= nil then
            custom_on_attach(client, bufnr)
        end
    end,
    capabilities = capabilities,
}

-- Disable tsserver formating
lspconfig['tsserver'].setup {
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false

        custom_on_attach(client, bufnr)
    end,
    capabilities = capabilities,
}

-- on Windows
local pid = vim.fn.getpid()
local omnisharp_bin = "C:\\Program Files\\omnisharp\\OmniSharp.exe"
lspconfig['omnisharp'].setup {
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) },
    on_attach = custom_on_attach,
}

vim.diagnostic.config {
    update_in_insert = true,
    float = {
        focusable = false
    }
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        focusable = false
    }
)


-- ----------------------------------
--           Completion
-- ----------------------------------

local has_words_before = function()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require("cmp")

cmp.setup {
    sources = cmp.config.sources({
        { name = 'vsnip' }, -- For vsnip users.
        { name = 'nvim_lsp' },
        { name = 'path' }
    }),
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
    },
}


-- ----------------------------------
--           Treesitter
-- ----------------------------------

require'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    highlight = {
        enable = true,              -- false will disable the whole extension
    },
    indent = {
        enable = true,
    },
}


-- require('lspfuzzy').setup {}


require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'solarized_dark',
        globalstatus = true,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    tabline = {
        lualine_a = {
            {
                'tabs',
                max_length = vim.o.columns,
                mode = 1,
            }
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    }
}

require('nvim-autopairs').setup {}


-- ----------------------------------
--           Neogit
-- ----------------------------------

require('neogit').setup {}
