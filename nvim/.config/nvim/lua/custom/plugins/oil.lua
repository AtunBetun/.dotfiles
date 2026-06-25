return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			default_file_explorer = true,
			view_options = { show_hidden = true },
		})
		vim.keymap.set("n", "<leader>po", "<cmd>Oil<CR>", { desc = "Open Oil" })
	end,
}
