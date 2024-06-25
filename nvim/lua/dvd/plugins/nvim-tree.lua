return {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        local nt = require('nvim-tree')

        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        nt.setup({
            view = {
                width = 35,
                relativenumber = true,
            },
            actions = {
                open_file = {
                    window_picker = {
                        enable = true,
                    },
                },
            },
            filters = {
                dotfiles = true,
            },
            renderer = {
                indent_markers = {
                    enable = true,
                },
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                        },
                    },
                },
            },
            git = {
                ignore = false,
            },
        })

        -- Keymaps
        vim.keymap.set('n', '<leader>ee',
            '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
        vim.keymap.set('n', '<leader>ef',
            '<cmd>NvimTreeFocus<CR>', { desc = 'Focus on file explorer' })
        vim.keymap.set('n', '<leader>ec',
            '<cmd>NvimTreeCollapse<CR>', { desc = 'Collapse file explorer' })
        vim.keymap.set('n', '<leader>er',
            '<cmd>NvimTreeRefresh<CR>', { desc = 'Refresh file explorer' })
    end
}
