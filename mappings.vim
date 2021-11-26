" Set leader key
let mapleader = " "

" Go down/up in wrapped lines
nnoremap j gj
nnoremap k gk

" Easier to escape the insert mode and terminal mode
inoremap jk <Esc>
inoremap kj <Esc>
tnoremap jk <Esc>
tnoremap kj <Esc>

" Splits mappings
noremap <leader>h <C-W><C-H>
noremap <leader>j <C-W><C-J>
noremap <leader>k <C-W><C-K>
noremap <leader>l <C-W><C-L>
noremap <leader>t <C-W><C-T>

" ----------------------------------
"           fzf.vim
" ----------------------------------
nnoremap <leader>/ :Ag<cr>
nnoremap <leader>f :Files<cr>
nnoremap <leader>b :Buffers<cr>


" ----------------------------------
"           lsp client
" ----------------------------------
lua << EOF
function _G.bufferLspMappings(client, bufnr)
    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn',  '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',          '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',           '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi',          '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',          '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs',          '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gw',          '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)

    -- Next/Prev diagnostic
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[g',          '<cmd>PrevDiagnostic<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']g',          '<cmd>NextDiagnostic<CR>', opts)

    -- Restart client
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rr',  '<cmd>lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>', opts)
end
EOF
