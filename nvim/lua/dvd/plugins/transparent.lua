return {
    'xiyaowong/transparent.nvim',
    config = function()
        local tp = require('transparent')

        tp.setup({
            extra_groups = {
                'EndOfBuffer',
                'NormalFloat',
                'Directory',
                'LineNr',
                'SignColumn',
            },
        })

        tp.clear_prefix('BufferLine')
        tp.clear_prefix('NvimTree')
    end,
}
