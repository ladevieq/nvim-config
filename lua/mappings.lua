-- Set leader key
vim.g.mapleader = ' '

local api = vim.api

if vim.fn.has('win32') == 1 then
    api.nvim_set_keymap('n', '<C-Z>', '<Nop>', {})
    api.nvim_set_keymap('v', '<C-Z>', '<Nop>', {})
    api.nvim_set_keymap('i', '<C-Z>', '<Nop>', {})
end

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
api.nvim_set_keymap('n', '<leader>/', ':FzfLua grep_project<cr>', {})
api.nvim_set_keymap('n', '<leader>f', ':FzfLua files<cr>', {})
api.nvim_set_keymap('n', '<leader>b', ':FzfLua buffers<cr>', {})

-- ----------------------------------
--           lsp client
-- ----------------------------------
function _G.bufferLspMappings(client, bufnr)
    local opts = { noremap = true, silent = true }
    api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn',   '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gd',           '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gD',           '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'K',            '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gi',           '<cmd>FzfLua lsp_implementations<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gr',           '<cmd>FzfLua lsp_references<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gs',           '<cmd>FzfLua lsp_document_symbols<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gw',           '<cmd>FzfLua lsp_live_workspace_symbols<CR>', opts)

    -- Next/Prev diagnostic
    api.nvim_buf_set_keymap(bufnr, 'n', '[g',           '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', ']g',           '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', ',<leader>g',   '<cmd>lua vim.diagnostic.setqflist()<CR>', opts)

    -- Restart client
    api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rr',   '<cmd>lua vim.lsp.stop_client(vim.lsp.get_active_clients())<CR>', opts)
end

api.nvim_set_keymap('n', '<F5>', '<cmd>silent vert copen 75 | AsyncRun -program=make<cr>', {})
