return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'nvim-tree/nvim-web-devicons',
        'folke/todo-comments.nvim'
    },
    config = function()
        local ts = require('telescope')
        local ac = require('telescope.actions')

        ts.setup({
            defaults = {
                path_display = { 'smart' },
                mappings = {
                    i = {
                        ["<C-k>"] = ac.move_selection_previous,
                        ["<C-j>"] = ac.move_selection_next,
                        ["<C-q>"] = ac.send_selected_to_qflist + ac.open_qflist,
                    },
                },
            },
        })

        ts.load_extension('fzf')

        -- Keymaps
        local km = vim.keymap

        km.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>',
            { desc = 'Fuzzy find files in cwd' })
        km.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>',
            { desc = 'Fuzzy find recent files' })
        km.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>',
            { desc = 'Find string in cwd' })
        km.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>',
            { desc = 'Find string under cursor in cwd' })
        km.set('n', '<leader>ft', '<cmd>TodoTelescope<CR>',
            { desc = 'Find todos' })
    end,
}
