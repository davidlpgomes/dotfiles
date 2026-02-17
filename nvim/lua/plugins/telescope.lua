return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        local ts = require('telescope')
        local ac = require('telescope.actions')

        ts.setup({
            defaults = {
                path_display = { 'smart' },
                mappings = {
                    i = {
                        ['<c-k>'] = ac.move_selection_previous,
                        ['<c-j>'] = ac.move_selection_next,
                        ['<c-q>'] = ac.send_selected_to_qflist + ac.open_qflist,
                    },
                },
            },
        })

        ts.load_extension('fzf')

        -- keymaps
        local km = vim.keymap

        km.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'fuzzy find files in cwd' })
        km.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'fuzzy find recent files' })
        km.set('n', '<leader>fs', '<cmd>Telescope live_grep<cr>', { desc = 'find string in cwd' })
        km.set('n', '<leader>fc', '<cmd>Telescope grep_string<cr>', { desc = 'find string under cursor in cwd' })
    end,
}
