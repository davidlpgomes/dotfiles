return {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local c = require('conform')

        c.setup({
            formatters_by_ft = {
                -- Essential
                c = { 'clang-format' },
                cpp = { 'clang-format' },
                java = { 'google-java-format' },
                lua = { 'stylua' },
                python = { 'isort', 'yapf' },
                rust = { 'rustfmt' },

                -- Web
                javascript = { 'prettier' },
                typescript = { 'prettier' },
                css = { 'prettier' },
                html = { 'prettier' },

                -- Utils
                json = { 'prettier' },
                yaml = { 'prettier' },
                markdown = { 'prettier' },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        })

        vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
            c.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = 'Format file or range (in visual mode)' })
    end,
}
