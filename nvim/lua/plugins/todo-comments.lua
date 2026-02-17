return {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    config = function()
        local tc = require('todo-comments')

        tc.setup()

        -- keymaps
        local km = vim.keymap

        km.set('n', '<leader>ft', '<cmd>TodoTelescope<cr>', { desc = 'find todos' })

        km.set('n', ']t', function()
            tc.jump_next()
        end, { desc = 'Next todo comment' })

        km.set('n', '[t', function()
            tc.jump_prev()
        end, { desc = 'Previous todo comment' })
    end,
}
