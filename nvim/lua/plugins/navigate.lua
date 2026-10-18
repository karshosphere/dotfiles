-------------------------------------------------------------------------------
--# Navigate #-----------------------------------------------------------------

vim.pack.add({
    'https://github.com/nvim-telescope/telescope.nvim', -- fuzzy finder
    'https://github.com/nvim-lua/plenary.nvim',         -- telescope dependency
})

--# Telescope #----------------------------------------------------------------

local telescope = require('telescope')

telescope.setup{
	defaults = {
		layout_config = {
			horizontal = {
				preview_width = 0.55,
				results_width = 0.45,
			},
			vertical = {
				preview_height = 0.6,
			},
			width = 0.8,
			height = 0.8,
		},
		layout_strategy = 'horizontal',
		selection_caret = "▶ ",
        prompt_prefix = " ",

	},
}

telescope.load_extension('noice')

local builtin = require('telescope.builtin')

Map('n', '<space>z', builtin.git_files)
Map('n', '<space>x', builtin.buffers)
Map('n', '<space>c', builtin.find_files)
Map('n', '<space>m', builtin.marks)

Map('n', '<space>n', ':Telescope noice<CR>')
Map('n', '<sapce>g', builtin.live_grep)
Map('n', '<space>v', builtin.registers)
Map('n', '<space>?', builtin.keymaps)
