return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
        local ll = require('lualine')
        local lazy_status = require('lazy.status')

        ll.setup({
            options = {
                theme = 'horizon',
                component_separators = '',
                section_separators = '',
                disabled_filetypes = {
                    'NvimTree',
                },
            },
            sections = {
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = '#ff9e64' },
                    },
                    { 'encoding' },
                    { 'fileformat' },
                    { 'filetype' },
                },
            },
        })
    end,
}
