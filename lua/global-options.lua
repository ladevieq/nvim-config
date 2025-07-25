local set = vim.opt
local global = vim.g

-- Set leader key
global.mapleader = ' '

-- Save and backup
-- Protect changes between writes. Default values of
-- updatecount (200 keystrokes) and updatetime
-- (4 seconds) are fine
set.swapfile = true

-- protect against crash-during-write
set.writebackup = true
-- but do not persist backup after successful write
set.backup = false
-- use rename-and-write-new method whenever safe
set.backupcopy = 'auto'

-- persist the undo tree for each file
set.undofile = true

-- Always use utf-8 encoding
set.encoding = 'utf-8'

-- Use unix end of line
if set.modifiable:get() then
    set.fileformats = { 'unix', 'dos' }
end

-- Indentation
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

-- Display location hints
set.number = true
set.relativenumber = true
set.cursorline = true

-- Visual hints
set.list = true
set.listchars = { tab = '>-', space = '·', eol = '¬' }
set.backspace = { 'indent', 'eol', 'start' }

-- Gui
if vim.fn.has('gui_running') == 1 then
    -- start maximised
    local MaximiseGroup = vim.api.nvim_create_augroup("MaximiseGroup", { clear = true })
    vim.api.nvim_create_autocmd("GUIEnter", { command = "simalt ~x", group = MaximiseGroup, pattern = { "*" } })

    if vim.fn.has('win32') == 1 then
        set.renderoptions = 'type:directx'
        set.guifont = 'Fira Code:h12'
    else
        set.guifont = 'Fira Code 12'
    end
    set.guioptions.remove('m', 'T', 'r', 'L')  -- remove menubar, toolbar, right-hand & left-hand scroll bar
end

set.path:append('**')
set.mouse:append('a')
set.wildmenu = true
set.splitbelow = true
set.splitright = true

-- Better display for messages
set.cmdheight = 2

-- always show signcolumns
set.signcolumn = 'yes'

-- Hide mode
set.showmode = false

set.scrolloff = 10 -- show lines above and below cursor

set.foldenable = false

-- Change diff algorithm
if set.diff:get() then
    set.diffopt = 'filler'
    set.diffopt:append('context:99999999')
    set.diffopt:append('linematch:60')
    set.fillchars:append('diff: ,')
    set.relativenumber = false

    if vim.fn.has("patch-8.1.0360") == 1 then
        set.diffopt:append('internal,algorithm:patience')
    end
end

-- Timeouts
set.timeout = true
set.timeoutlen = 150
set.ttimeoutlen = 150
set.updatetime = 1000

-- Use system clipboard
set.clipboard = 'unnamedplus'

set.termguicolors = true

set.virtualedit = block

-- Set completeopt to have a better completion experience
set.completeopt = { 'menu', 'menuone', 'noselect' }

-- Avoid showing message extra message when using completion
set.shortmess:append('c')

-- Allows easy find and replace throught the whole project
set.grepprg = 'rg --vimgrep --smart-case --follow'

-- Use and set powershell options if it is installed
if vim.fn.has('win32') == 1 then
    global.terminal_emulator = vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell'

    set.shell = vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell'
    set.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    set.shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    set.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set.shellquote = ""
    set.shellxquote= ""
end

global.editorconfig = false
