return {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
        'windwp/nvim-ts-autotag',
    },
    config = function()
        local ts = require('nvim-treesitter.configs')

        ts.setup({
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            autotag = {
                enable = true,
            },
            ensure_installed = {
                -- Programming Lang. Essential
                'asm',
                'c',
                'cpp',
                'java',
                'lua',
                'python',
                'r',
                'rust',

                -- Web
                'css',
                'html',
                'javascript',
                'scss',
                'typescript',

                -- Utils
                'bash',
                'bibtex',
                'diff',
                'dockerfile',
                'gitignore',
                'json',
                'make',
                'markdown',
                'markdown_inline',
                'objdump',
                'regex',
                'toml',
                'vim',
                'vimdoc',
                'xml',
                'yaml',
                'yuck',
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<C-space>',
                    node_incremental = '<C-space>',
                    scope_incremental = false,
                    node_decremental = '<bs>',
                },
            },
        })
    end,
}
