set runtimepath^=~/.vim runtimepath+=~/.vim/after

" Save and backup
" Protect changes between writes. Default values of
" updatecount (200 keystrokes) and updatetime
" (4 seconds) are fine
set swapfile
set directory^=~/.vim/swap//

" protect against crash-during-write
set writebackup
" but do not persist backup after successful write
set nobackup
" use rename-and-write-new method whenever safe
set backupcopy=auto
" patch required to honor double slash at end
if has("patch-8.1.0251")
    " consolidate the writebackups -- not a big
    " deal either way, since they usually get deleted
    set backupdir^=~/.vim/backup//
end

" persist the undo tree for each file
set undofile
set undodir^=~/.vim/undo//

" Always use utf-8 encoding
set encoding=utf-8

" Indentation
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

filetype plugin indent on

" Display location hints
set number
set relativenumber
set cursorline

" Visual hints
set list
set lcs=tab:>-,space:·,eol:¬
set backspace=indent,eol,start

" Gui
if has('gui_running')
    " start maximised
    au GUIEnter * simalt ~x

    if has("win32")
        set renderoptions=type:directx
        set guifont=Fira\ Code:h12
    else
        set guifont=Fira\ Code\ 12
    endif
    set guioptions-=m  "remove menubar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
endif

set path+=**
set mouse+=a
set wildmenu
set splitbelow
set splitright

set autoread

" Better display for messages
set cmdheight=2

" always show signcolumns
set signcolumn=yes

" Hide mode
set noshowmode

" Search
set incsearch
set hlsearch

set scrolloff=10 " show lines above and below cursor

" Note, perl automatically sets foldmethod in the syntax file
" autocmd Syntax c,cpp,json,xml,html,js,vue setlocal foldmethod=syntax
" autocmd Syntax c,cpp,json,xml,html,js,vue normal zR
set nofoldenable

" Change diff algorithm
if &diff
    set diffopt=filler,context:99999999
    set fillchars+=diff:\ ,
    set norelativenumber

    if has("patch-8.1.0360")
        set diffopt+=internal,algorithm:patience
    endif
endif

" Timeouts
set timeout
set timeoutlen=250
set ttimeout
set ttimeoutlen=100
set updatetime=300

" Use system clipboard
set clipboard=unnamedplus

syntax on
set t_Co=256

filetype plugin on

" Enable true colors when available
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

set virtualedit=block

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c
