--------------------------------------------------------------------------------
--# Editor #--------------------------------------------------------------------

vim.pack.add({
    'https://github.com/numToStr/Comment.nvim',          -- easier commenting
    'https://github.com/kylechui/nvim-surround',         -- more surround actions
    'https://github.com/karnull/ifdef.nvim',             -- surrounding #defines
    'https://github.com/Djancyp/better-comments.nvim',   -- colour coded comments
	'https://github.com/puremourning/vimspector',        -- debugger
    'https://github.com/lukas-reineke/indent-blankline.nvim',-- indent guides
	'https://github.com/YousefHadder/markdown-plus.nvim',    -- markdown preview
})

--# Enable Plugins #------------------------------------------------------------

require('Comment').setup()
require("nvim-surround").setup()
require('ifdef').setup()

vim.g.vimspector_enable_mappings = 'HUMAN'


--# Keybinds #------------------------------------------------------------------

Map('ni', '<leader>h',  ':Ifdef current<CR>') -- surrounding defines
Map('n', '<leader>u',  ':UndotreeToggle<CR>') -- undo tree


--# Better Comments #-----------------------------------------------------------

require('better-comment').Setup({
    tags = {{
        name = "TODO",
        fg = "white",
        bg = "#0a7aca",
        bold = true,
        virtual_text = "",
    },{
        name = "FIX",
        fg = "white",
        bg = "#f44747",
        bold = true,
        virtual_text = "",
    },{
        name = "WARNING",
        fg = "#FFA500",
        bg = "",
        bold = false,
        virtual_text = "",
    },{
        name = "!",
        fg = "#f44747",
        bg = "",
        bold = true,
        virtual_text = "",
    }}
})


--# Indent Blankline #----------------------------------------------------------

local hooks = require("ibl.hooks")

-- Define your highlight groups
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "IndentDark", { fg = "#2f4f4f" })
    vim.api.nvim_set_hl(0, "IndentStrong", { fg = "#ff5f87" })
end)

-- Setup indent-blankline
require("ibl").setup {
    indent = {
        highlight = {
            "IndentDark",
            "IndentDark",
            "IndentDark",
            "IndentDark",
            "IndentDark",
            "IndentDark",
            "IndentStrong",
        },
    },
    scope = {
        enabled = true,
        highlight = "IndentStrong",
    },
}

--# Markdown Preview #----------------------------------------------------------

require("markdown-plus").setup()

-- usage

-- <leader>lt +
--   u    unordered (-)
--   t    task (- [ ])
--   n    numbered (1.)
--   N    numbered paren (1))
--   l    lowercase letter (a.)
--   L    uppercase letter (A.)
--   p    lowercase letter paren (a))
--   P    uppercase letter paren (A))
--   c    clear (strip all list markers)

-- clear all highlight: <leader>mF

-- select codeblock: <leader>mc

-- Headings:
--    Use ]] and [[ to jump between headers quickly
--    <leader>h+ Higher heading
--    <leader>h- Lower heading
--    <leader>h<num> Make that heading
