return {
    'ntpeters/vim-better-whitespace',
    event = { 'BufReadPre', 'BufNewFile' },
    init = function()
        vim.g.better_whitespace_guicolor = '#FD98B9'
        vim.g.strip_whitespace_on_save = 1
    end,
}
