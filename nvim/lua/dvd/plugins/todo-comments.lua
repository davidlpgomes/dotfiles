return {
    'folke/todo-comments.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    config = function()
        local tc = require('todo-comments')

        local km = vim.keymap

        km.set('n', ']t', function()
            tc.jump_next()
        end, { desc = 'Next todo comment' })

        km.set('n', '[t', function()
            tc.jump_prev()
        end, { desc = 'Previous todo comment' })

        tc.setup()
    end,
}
