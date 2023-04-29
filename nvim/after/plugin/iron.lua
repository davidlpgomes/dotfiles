local iron = require('iron.core')
local view = require('iron.view')

iron.setup({
    scratch_repl = true,
    config = {
        repl_definition = {
            python = {
                command = {'ipython', '--profile=iron'},
                format = require('iron.fts.common').bracketed_paste,
            },
            sh = {
                command = {'zsh'}
            }
        },
        repl_open_cmd = view.split.vertical.botright(70),
    },
    keymaps = {
        send_motion = '<leader>sc',
        visual_send = '<leader>sc',
        exit = '<leader>sq',
    },
    ignore_blank_lines = true,
})

vim.keymap.set('n', '<leader>rs', '<cmd>IronRepl<cr>')

