vim.cmd('let g:netrw_liststyle = 3')

local opt = vim.opt

opt.nu = true
opt.relativenumber = true

-- Tab & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

opt.autoindent = true
opt.wrap = true

-- List chars
opt.list = true
opt.listchars = {
    trail = '⋅',
    tab = '>-',
}

-- Search
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

-- Undofile
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- Backspace
opt.backspace = 'indent,eol,start'

-- Clipboard
opt.clipboard:append('unnamedplus')

-- Split
opt.splitright = true
opt.splitbelow = true

-- Others
opt.termguicolors = true
opt.colorcolumn = "80"

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

opt.updatetime = 50
