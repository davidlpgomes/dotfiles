return {
    'williamboman/mason.nvim',
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
        local mason = require('mason')
        local mason_lspconfig = require('mason-lspconfig')
        local mti = require('mason-tool-installer')

        mason.setup({
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                    package_uninstalled = '✗',
                },
            },
        })

        mason_lspconfig.setup({
            ensure_installed = {
                'asm_lsp',
                'bashls',
                'clangd',
                'cssls',
                'dockerls',
                'docker_compose_language_service',
                'html',
                'jdtls',
                'tsserver',
                'ltex',
                'lua_ls',
                'autotools_ls',
                'markdown_oxide',
                'pyright',
                'somesass_ls',
                'rust_analyzer',
            },
        })

        mti.setup({
            ensure_installed = {
                -- Formatters
                'google-java-format',
                'isort',
                'prettier',
                'rustfmt',
                'stylua',
                'yapf',

                -- Linters
                'eslint_d',
                'flake8',
                'pydocstyle',
            },
        })
    end,
}
