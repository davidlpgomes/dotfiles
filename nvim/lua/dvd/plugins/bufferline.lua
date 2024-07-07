return {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    version = '*',
    opts = {
        options = {
            mode = 'tabs',
            indicator = {
                style = 'none',
            },
            tab_size = 20,
            diagnostics = 'nvim_lsp',
            separator_style = 'thin',
            always_show_bufferline = false,
        },
    },
}
