return {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        indent = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
        },
        scroll = { enabled = true },
    },
}
