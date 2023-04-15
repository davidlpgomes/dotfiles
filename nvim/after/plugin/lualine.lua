lualine = require('lualine')

lualine.setup({
    options = {
        theme = 'horizon',
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
            'NvimTree',
            'packer',
        }
    }

})
