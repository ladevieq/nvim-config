let s:homeConfig = empty($XDG_CONFIG_HOME) ? $HOME . '/.config/nvim' : $XDG_CONFIG_HOME
execute 'source ' . s:homeConfig . '/global-options.vim'
execute 'source ' . s:homeConfig . '/plugins.vim'
execute 'source ' . s:homeConfig . '/mappings.vim'

" Filetype specific
autocmd Filetype c setlocal cc=81 
autocmd Filetype cpp setlocal cc=81 

let g:nvcode_termcolors=256
colorscheme nvcode
"
" lightline colorscheme
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ]
      \ },
      \ }

" ----------------------------------
"           fzf.vim
" ----------------------------------

lua << EOF
require('lspfuzzy').setup {}
EOF

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

" Mappings
augroup LSP
    autocmd!

    autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()
augroup END

set omnifunc=v:lua.vim.lsp.omnifunc

" Servers setup
lua << EOF

local lspconfig = require("lspconfig")

function custom_on_attach(client, bufnr)
    -- Setup mappings only for buffer with a server
    bufferLspMappings(client, bufnr)
end

lspconfig.tsserver.setup        { on_attach = custom_on_attach }

lspconfig.clangd.setup          { on_attach = custom_on_attach }

lspconfig.rust_analyzer.setup   { on_attach = custom_on_attach }

lspconfig.efm.setup             {}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = true,
    }
)

EOF


" ----------------------------------
"           Treesitter
" ----------------------------------
lua <<EOF

require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
        enable = true,              -- false will disable the whole extension
    },
    indent = {
        enable = true,
    },
}

EOF
