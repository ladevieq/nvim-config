let s:homeData = empty($XDG_DATA_HOME) ? $HOME . '/.local/share' : $XDG_DATA_HOME
let s:vimPlugPath = s:homeData . '/nvim/site/autoload/plug.vim'

if empty(glob(s:vimPlugPath))
    echo s:vimPlugPath
    execute 'silent !curl -fLo ' . s:vimPlugPath . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin(stdpath('data') . '/plugged')

Plug 'ChristianChiarulli/nvcode-color-schemes.vim'

Plug 'machakann/vim-sandwich'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'  " to enable preview (optional)
Plug 'ojroques/nvim-lspfuzzy', {'branch': 'main'}

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'itchyny/lightline.vim'

call plug#end()

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

