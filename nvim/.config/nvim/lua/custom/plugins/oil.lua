return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({

			view_options = {
				show_hidden = true,
			},
		})
		vim.api.nvim_set_keymap("n", "<leader>po", ":Oil<CR>", { noremap = true, silent = true })
	end,
}
