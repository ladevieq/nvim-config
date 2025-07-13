local api = vim.api
local fn = vim.fn

local function feedkeys(keys)
    api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
end

local function pumvisible()
    return tonumber(fn.pumvisible()) ~= 0
end

if fn.has('win32') == 1 then
    api.nvim_set_keymap('n', '<C-Z>', '<Nop>', {})
    api.nvim_set_keymap('v', '<C-Z>', '<Nop>', {})
    api.nvim_set_keymap('i', '<C-Z>', '<Nop>', {})
end

-- Go down/up in wrapped lines
-- api.nvim_set_keymap('n', 'j', 'gj', {})
-- api.nvim_set_keymap('n', 'k', 'gk', {})

-- Easier to escape the insert mode and terminal mode
api.nvim_set_keymap('i', 'jk', '<Esc>', {})
api.nvim_set_keymap('i', 'kj', '<Esc>', {})

-- Splits mappings
api.nvim_set_keymap('n', '<leader>h', '<C-W><C-H>', {})
api.nvim_set_keymap('n', '<leader>j', '<C-W><C-J>', {})
api.nvim_set_keymap('n', '<leader>k', '<C-W><C-K>', {})
api.nvim_set_keymap('n', '<leader>l', '<C-W><C-L>', {})
api.nvim_set_keymap('n', '<leader>t', '<C-W><C-T>', {})

-- Restart neovim
api.nvim_set_keymap('n', 'rr', '<cmd>:restart<cr>', {})

-- ----------------------------------
--           fzf.vim
-- ----------------------------------
api.nvim_create_user_command('FD', function(opts)
    local fzf = require'fzf-lua'
    local args = fzf.config.setup_opts.files.fd_opts.." "..opts.args
    fzf.fzf_exec(
        "fd "..args,
        {
            cwd = fzf.config.cwd,
            actions = fzf.defaults.actions.files
        }
    )
end, { nargs='*' })

api.nvim_set_keymap('n', '<leader>/', ':FzfLua live_grep_native<cr>', {})
api.nvim_set_keymap('n', '<leader>f', ':FD<cr>', {})
api.nvim_set_keymap('n', '<leader>b', ':FzfLua buffers<cr>', {})

-- ----------------------------------
--           lsp client
-- ----------------------------------
function _G.buffer_lsp_mappings(client, bufnr)
    local opts = { noremap = true, silent = true }

    api.nvim_buf_set_keymap(bufnr, 'n', 'gd',           '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    api.nvim_buf_set_keymap(bufnr, 'n', 'gw',           '<cmd>FzfLua lsp_live_workspace_symbols<CR>', opts)

    -- Restart client
    api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rr',   '<cmd>lua vim.lsp.stop_client(vim.lsp.get_clients()) | edit <CR>', opts)

    -- completion
    api.nvim_buf_set_keymap(bufnr, 'i', '<cr>', '',
        {
            noremap = true,
            silent = true,
            callback = function()
                if pumvisible() then
                    feedkeys('<C-y>')
                else
                    feedkeys('<cr>')
                end
            end
        }
    )
    api.nvim_buf_set_keymap(bufnr, 'i', '<Tab>', '',
        {
            noremap = true,
            silent = true,
            callback = function()
                if pumvisible() then
                    feedkeys('<C-n>')
                else
                    feedkeys('<Tab>')
                end
            end, 
        }
    )
    api.nvim_buf_set_keymap(bufnr, 'i', '<S-Tab>', '',
        {
            noremap = true,
            silent = true,
            callback = function()
                if pumvisible() then
                    feedkeys('<C-p>')
                else
                    feedkeys('<S-Tab>')
                end
            end, 
        }
    )
    api.nvim_buf_set_keymap(bufnr, 'i', '/', '',
        {
            noremap = true,
            silent = true,
            callback = function()
                if pumvisible() then
                    feedkeys('<C-e>')
                else
                    feedkeys('/')
                end
            end, 
        }
    )
end

-- ----------------------------------
--           terminal
-- ----------------------------------
api.nvim_set_keymap('t', 'jk', '<C-\\><C-N>', {})

local async = require('vim._async')
local task = nil
local stat = vim.loop.fs_stat(fn.getcwd().."\\build.bat")
if stat and stat.type or false then
    vim.opt.makeprg = './build.bat'

    api.nvim_set_keymap('n', '<F5>', '', {
        callback = function()
            -- TODO: Remove once vim._async works
            -- vim.cmd('silent vert copen '..math.floor(vim.o.columns * 0.45)..' | AsyncRun -program=make')
            vim.cmd('silent vert copen '..math.floor(vim.o.columns * 0.45))

            task = async.run(function()
                vim.cmd('make')
            end)
        end,
    })
end
