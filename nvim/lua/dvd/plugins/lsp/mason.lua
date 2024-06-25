return {
    'williamboman/mason.nvim',
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
    },
    config = function()
        local mason = require('mason')
        local mason_lspconfig = require('mason-lspconfig')

        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
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
    end,
}
