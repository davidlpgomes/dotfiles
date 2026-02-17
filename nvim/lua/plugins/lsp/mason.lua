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
                'autotools_ls', -- autotools-language-server
                'bashls', -- bash-language-server
                'clangd',
                'cssls',
                'docker_language_server', -- docker-language-server
                'html', -- html-lsp
                'jdtls',
                'lua_ls', -- lua-language-server
                'markdown_oxide', -- markdown-oxide
                'pyright',
                'ruff',
                'rust_analyzer', -- rust-analyzer',
                'ty',
            },
        })

        mti.setup({
            ensure_installed = {
                -- Love you ruff
                'ruff',
                'ty',

                -- Formatters
                'clang-format',
                'google-java-format',
                'prettier',
                'stylua',

                -- Linters
                'eslint_d',
                'mypy',
            },
        })
    end,
}
