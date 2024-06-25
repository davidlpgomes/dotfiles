return {
    'xiyaowong/transparent.nvim',
    config = function()
        local tp = require('transparent')

        tp.setup({
            extra_groups = {
                'EndOfBuffer',
                'NormalFloat',
                'Directory',
                'LineNr',
                'SignColumn',
                -- NvimTree
                'NvimTreeNormal',
                'NvimTreeNormalNC',
                'NvimTreeFolderIcon',
                'NvimTreeFolderName',
                'NvimTreeOpenedFolderName',
                'NvimTreeEmptyFolderName',
                'NvimTreeIndentMarker',
                'NvimTreeRootFolder',
                'NvimTreeImageFile',
                'NvimTreeSpecialFile',
                'NvimTreeSymlink',
                'NvimTreeSymlinkFolderName',
            },
        })
    end
}
