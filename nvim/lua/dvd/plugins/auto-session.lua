return {
    'rmagatti/auto-session',
    config = function()
        local as = require('auto-session')

        as.setup({
            auto_restore_enabled = false,
            auto_session_suppress_dirs = {
                '~/', '~/code', '~/Downloads', '~/Documents'
            },
        })

        -- Keymap
        local km = vim.keymap

        km.set('n', '<leader>wr', '<cmd>SessionRestore<CR>',
            { desc = 'Restore session for cwd' })
        km.set('n', '<leader>ws', '<cmd>SessionSave<CR>',
            { desc = 'Save session for auto session root dir' })
    end,
}
