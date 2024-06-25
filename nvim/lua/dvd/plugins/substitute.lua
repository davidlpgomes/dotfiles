return {
    'gbprod/substitute.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local s = require('substitute')

        s.setup()

        local km = vim.keymap

        km.set('n', 's', s.operator, { desc = 'Substitute with motion' })
        km.set('n', 'ss', s.line, { desc = 'Substitute line' })
        km.set('n', 'S', s.eol, { desc = 'Substitute to end of line' })
        km.set('x', 's', s.visual, { desc = 'Substitute in visual mode'})
    end,
}
