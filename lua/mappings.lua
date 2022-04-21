-- Set leader key
vim.g.mapleader = ' '

local api = vim.api

-- Go down/up in wrapped lines
api.nvim_set_keymap('n', 'j', 'gj', {})
api.nvim_set_keymap('n', 'k', 'gk', {})

-- Easier to escape the insert mode and terminal mode
api.nvim_set_keymap('i', 'jk', '<Esc>', {})
api.nvim_set_keymap('i', 'kj', '<Esc>', {})

-- Splits mappings
api.nvim_set_keymap('n', '<leader>h', '<C-W><C-H>', {})
api.nvim_set_keymap('n', '<leader>j', '<C-W><C-J>', {})
api.nvim_set_keymap('n', '<leader>k', '<C-W><C-K>', {})
api.nvim_set_keymap('n', '<leader>l', '<C-W><C-L>', {})
api.nvim_set_keymap('n', '<leader>t', '<C-W><C-T>', {})

-- ----------------------------------
--           fzf.vim
-- ----------------------------------
api.nvim_set_keymap('n', '<leader>/', ':Telescope live_grep<cr>', {})
api.nvim_set_keymap('n', '<leader>f', ':Telescope find_files<cr>', {})
api.nvim_set_keymap('n', '<leader>b', ':Telescope buffer<cr>', {})

-- ----------------------------------
--           lsp client
-- ----------------------------------
function _G.bufferLspMappings(client, bufnr)
    local opts = { noremap = true, silent = true }
    api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn',   '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gd',           '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'K',            '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gi',           '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gr',           '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gs',           ':Telescope lsp_document_symbols<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gw',           ':Telescope lsp_workspace_symbols<CR>', opts)

    -- Next/Prev diagnostic
    api.nvim_buf_set_keymap(bufnr, 'n', '[g',           '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', ']g',           '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', ',<leader>g',   '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)

    -- Restart client
    api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rr',   '<cmd>lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>', opts)
end
