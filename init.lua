require('plugins')
require('global-options')
require('mappings')

local api = vim.api
local global = vim.g
local cmd = vim.cmd
local env = vim.env
local fn = vim.fn

local FTDetectGroup = api.nvim_create_augroup("FTDetect", { clear = true })
api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    { command = "setfiletype glsl", group = FTDetectGroup, pattern = { "*.fx", "*.hlsl", "*.comp" }}
)

cmd [[colorscheme github_dark_colorblind]]

-- ----------------------------------
--           Nvim LSP client
-- ----------------------------------

local CursorHoldGroup = api.nvim_create_augroup("LSP", { clear = true })
api.nvim_create_autocmd("CursorHold", { command = "lua vim.diagnostic.open_float()", group = CursorHoldGroup, pattern = { "*" }})

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;

function custom_on_attach(client, bufnr)
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Setup mappings only for buffer with a server
    bufferLspMappings(client, bufnr)
    if client.server_capabilities.document_formatting then
        local LSPFormattingGroup = api.nvim_create_augroup("LSPFormatting", {})
        api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.formatting_sync()", group = LSPFormattingGroup, pattern = { "<buffer>" }})
    end

    if client.server_capabilities.documentHighlightProvider then
        local DocumentHighlightGroup = api.nvim_create_augroup("LSPDocumentHighlight", { clear = true })
        api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { command = "lua vim.lsp.buf.document_highlight()", group = DocumentHighlightGroup, pattern = { "<buffer>" }})
        api.nvim_create_autocmd("CursorMoved", { command = "lua vim.lsp.buf.clear_references()", group = DocumentHighlightGroup, pattern = { "<buffer>" }})
    end
end

local servers = { 'rust_analyzer', 'gopls', 'cmake'}
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = custom_on_attach,
        capabilities = capabilities,
    }
end

-- Disable clangd auto formatting if there is not .clang-format
lspconfig['clangd'].setup {
    cmd = { "clangd", "--completion-style=detailed" },
    on_attach = function(client, bufnr)
        local cwd = vim.fn['getcwd']()
        client.server_capabilities.document_formating = lspconfig.util.root_pattern(".clang-format")(cwd) ~= nil
        custom_on_attach(client, bufnr)
    end,
    capabilities = capabilities,
}

-- Disable tsserver formating
lspconfig['tsserver'].setup {
    on_attach = function(client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false

        custom_on_attach(client, bufnr)
    end,
    capabilities = capabilities,
}

-- on Windows
local omnisharp_bin = "C:\\Program Files\\omnisharp\\OmniSharp.exe"
lspconfig['omnisharp'].setup {
    cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
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
cmp.setup({
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        { name = 'path' },
        { name = 'nvim_lsp_signature_help' },
    }),
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<Tab>']   = cmp.mapping.scroll_docs(-4),
        ['<S-Tab>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>']   = cmp.mapping.abort(),
        ['<CR>']    = cmp.mapping.confirm({ select = true }),
        ['<Tab>']   = cmp.mapping(function(fallback)
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
        ['<C-e>']   = cmp.mapping.abort(),
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    }
})


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


require('lualine').setup {
    options = {
        icons_enabled = false,
        globalstatus = true,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch'},
        lualine_c = {
            {
                'filename',
                path = 1,
            }
        },
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


require('nvim-autopairs').setup({})


-- ----------------------------------
--           FZF
-- ----------------------------------

local FZFGroup = api.nvim_create_augroup("FZF", { clear = true })
api.nvim_create_autocmd("CursorHold",   { command = "set laststatus=0 noruler", group = FZFGroup, pattern = { "FileType fzf"}})
api.nvim_create_autocmd("BufLeave",     { command = "set laststatus=2 ruler",   group = FZFGroup, pattern = { "<buffer>"    }})

global.fzf_buffers_jump = 1
api.nvim_create_user_command(
    'Ag',
    'call fzf#vim#ag(<q-args>, { "options" : "--delimiter : --nth 4.."}, <bang>0)',
    {
        bang = true,
        nargs = '*',
    }
)
api.nvim_create_user_command(
    'Rg',
    'call '..
        'fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>),'..
        '1,'..
        '{"options": "--delimiter : --nth 4.."},'..
        '<bang>0)',
    {
        bang = true,
        nargs = '*',
    }
)
api.nvim_create_user_command(
    'RAg',
    "call fzf#vim#ag_raw(<q-args>, { 'options' : '--delimiter : --nth 4..'}, <bang>0)",
    {
        bang = true,
        nargs = '+',
        complete = 'dir'
    }
)

local build_quickfix_list = function(lines)
    fn.setqflist(fn.map(fn.copy(lines), '{ "filename": v:val, "lnum": 1 }'))
    cmd 'copen'
    cmd 'cc'
end

global.fzf_preview_window = { 'hidden,right,50%', 'ctrl-/' }
global.fzf_action = {
    ['ctrl-q'] = 'call build_quickfix_list',
    ['ctrl-t'] = 'tab split',
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit'
}
global.fzf_layout = { window = { width = 0.8, height = 0.8, border = 'rounded' } }
global.fzf_colors = {
    ['fg'] =      { 'fg', 'Normal' },
    ['bg'] =      { 'bg', 'Normal' },
    ['hl'] =      { 'fg', 'Comment' },
    ['fg+'] =     { 'fg', 'CursorLine', 'CursorColumn', 'Normal' },
    ['bg+'] =     { 'bg', 'CursorLine', 'CursorColumn' },
    ['hl+'] =     { 'fg', 'Statement' },
    ['info'] =    { 'fg', 'PreProc' },
    ['gutter'] =  { 'fg', 'Ignore' },
    ['prompt'] =  { 'fg', 'Conditional' },
    ['pointer'] = { 'fg', 'Exception' },
    ['marker'] =  { 'fg', 'Keyword' },
    ['spinner'] = { 'fg', 'Label' },
    ['header'] =  { 'fg', 'Comment' }
}

require("clangd_extensions").prepare()
