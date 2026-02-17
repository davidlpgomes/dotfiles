return {
    'stevearc/oil.nvim',
    opts = {
        show_hidden = true,
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
        local oil = require('oil')

        oil.setup({})

        -- Keymaps
        vim.keymap.set('n', '<leader>o', '<cmd>Oil<CR>', { desc = 'Open Oil' })
    end,
}
