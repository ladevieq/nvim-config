-- TODO: Remove once vim.pack is stable
if 0 == 1 then
    local plug_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'
    if vim.fn.empty(vim.fn.glob(plug_path)) == 1 then
        vim.fn.execute('silent !curl -fLo ' .. plug_path .. ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    end

    local Plug = vim.fn['plug#']

    vim.call('plug#begin')
        -- Plug 'RRethy/base16-nvim'

        Plug 'machakann/vim-sandwich'
        Plug 'windwp/nvim-autopairs'

        Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' }) -- We recommend updating the parsers on update

        Plug('junegunn/fzf', {
            ['do'] = function()
                vim.call('fzf#install')
            end
        })
        Plug 'ibhagwan/fzf-lua'

        -- TODO: Removed once vim._async works
        -- Plug 'skywind3000/asyncrun.vim'

        -- Plug 'dstein64/vim-startuptime'
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
else
    local github = 'https://github.com/'
    vim.pack.add({
        -- github..'RRethy/base16-nvim',

        github..'machakann/vim-sandwich',
        github..'windwp/nvim-autopairs',
        github..'nvim-treesitter/nvim-treesitter',

        github..'junegunn/fzf',
        github..'ibhagwan/fzf-lua',

        -- TODO: Removed once vim._async works
        -- github..'skywind3000/asyncrun.vim',

        -- github..'dstein64/vim-startuptime',
    })
end
