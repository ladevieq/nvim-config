local plug_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'

if vim.fn.empty(vim.fn.glob(plug_path)) == 1 then
    vim.fn.execute('silent !curl -fLo ' .. plug_path .. ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
end

local Plug = vim.fn['plug#']

vim.call('plug#begin')

Plug 'andreasvc/vim-256noir'

Plug 'machakann/vim-sandwich'
Plug 'windwp/nvim-autopairs'

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' }) -- We recommend updating the parsers on update

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'

Plug('junegunn/fzf', {
    ['do'] = function()
        vim.call('fzf#install')
    end
})
Plug 'ibhagwan/fzf-lua'

Plug 'skywind3000/asyncrun.vim'

Plug 'dstein64/vim-startuptime'

vim.call('plug#end')

-- Run PlugInstall if there are missing plugins
local MissingPluginGroup = vim.api.nvim_create_augroup("MissingPlugin", { clear = true })
vim.api.nvim_create_autocmd(
    "VimEnter",
    {
        command = "if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif",
        group = MissingPluginGroup,
        pattern = { "*" }
    }
)
