return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {},
    config = function()
        local ts = require('nvim-treesitter')

        ts.install({
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
        }):wait(300000)
    end,
}
