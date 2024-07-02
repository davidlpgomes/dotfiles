return {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    version = '*',
    opts = {
        options = {
            mode = 'tabs',
            indicator = {
                icon = '|',
                style = 'underline',
            },
            tab_size = 20,
            diagnostics = 'nvim_lsp',
            separator_style = 'slant',
            always_show_bufferline = false,
        },
    },
}
