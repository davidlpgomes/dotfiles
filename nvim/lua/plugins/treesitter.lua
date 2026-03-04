return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
        local ts = require('nvim-treesitter.config')

        ts.setup({
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            ensure_installed = {
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
                'awk',
                'bash',
                'bibtex',
                'editorconfig',
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
        })
    end,
}
