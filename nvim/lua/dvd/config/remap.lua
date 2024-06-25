vim.g.mapleader = ' '

local km = vim.keymap

-- Move lines up/down
km.set('v', 'J', ":m '>+1<CR>gv=gv")
km.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Keeps cursor in the middle when scrolling
km.set('n', '<C-d>', '<C-d>zz')
km.set('n', '<C-u>', '<C-u>zz')

-- Execution / Perm
km.set('n', '<leader>x', '<cmd>!./%<CR>', { desc = 'Executes the file' })
km.set('n', '<leader>X', '<cmd>!chmod +x %<CR>',
    { silent = true, desc = 'Gives execution permission to file' })

-- Search
km.set('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights' })

-- Inc/dec numbers
km.set('n', '<leader>+', "<C-a>", { desc = 'Increment number' })
km.set('n', '<leader>-', "<C-x>", { desc = 'Decrement number' })

-- Window splits
km.set('n', '<leader>sv', "<C-w>v", { desc = 'Split window vertically' })
km.set('n', '<leader>sh', "<C-w>s", { desc = 'Split window horizontally' })
km.set('n', '<leader>se', "<C-w>=", { desc = 'Make splits equal size' })
km.set('n', '<leader>sc', '<cmd>close<CR>', { desc = 'Close current split' })

-- Tabs
km.set('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'Open new tab' })
km.set('n', '<leader>tc', '<cmd>tabclose<CR>', { desc = 'Close tab' })
km.set('n', '<leader>tn', '<cmd>tabn<CR>', { desc = 'Go to next tab' })
km.set('n', '<leader>tp', '<cmd>tabp<CR>', { desc = 'Go to previous tab' })
km.set('n', '<leader>tt', '<cmd>tabnew %<CR>', { desc = 'Current file in new tab' })
