execute 'source ' . stdpath('config') . '/plugins.vim'
execute 'source ' . stdpath('config') . '/global-options.vim'
execute 'source ' . stdpath('config') . '/mappings.vim'

augroup filetypedetect
    au! BufRead,BufNewFile *.fx             setfiletype glsl
augroup END

let g:vscode_style = "dark"
colorscheme vscode

" ----------------------------------
"           fzf.vim
" ----------------------------------

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Make ag match files content only, not filenames
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)


" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }


" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'window': { 'yoffset': 0.85, 'width': 0.9, 'height': 0.6 } }
let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-/']

" ----------------------------------
"           ! fzf.vim
" ----------------------------------

" ----------------------------------
"           Nvim LSP client
" ----------------------------------

augroup LSP
    autocmd!

    autocmd CursorHold * lua vim.diagnostic.open_float()
augroup END

set omnifunc=v:lua.vim.lsp.omnifunc

lua << EOF

local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

function custom_on_attach(client, bufnr)
    -- Setup mappings only for buffer with a server
    bufferLspMappings(client, bufnr)
end

local servers = { 'clangd', 'rust_analyzer', 'gopls'}
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = custom_on_attach,
        capabilities = capabilities,
    }
end

-- Disable tsserver formating
lspconfig['tsserver'].setup {
    on_attach = function(client, bufnr)
        custom_on_attach(client, bufnr)

        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
    capabilities = capabilities,
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
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
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
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
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
        ["<S-Tab>"] = cmp.mapping(function()
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
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true,              -- false will disable the whole extension
    },
    indent = {
        enable = true,
    },
}


require('lspfuzzy').setup {}


-- ----------------------------------
--           null-ls
-- ----------------------------------

require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.eslint,
        require("null-ls").builtins.diagnostics.eslint,
    },
    on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
            vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
            ]])
        end
    end,
})


require('lualine').setup {
    options = {
        icons_enabled = false,
        theme = 'solarized_dark',
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
EOF
