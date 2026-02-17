return {
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v3.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        lazy = false,
        config = function()
            local nt = require('neo-tree')

            nt.setup({})

            -- Keymaps
            vim.keymap.set('n', '<leader>ee', '<cmd>Neotree toggle<CR>', { desc = 'Toggle file explorer' })
            vim.keymap.set('n', '<leader>ef', '<cmd>Neotree focus<CR>', { desc = 'Focus on file explorer' })
            vim.keymap.set('n', '<leader>gs', '<cmd>Neotree float git_status<CR>', { desc = 'Git status' })
        end,
    },
}
