return {
	"ThePrimeagen/harpoon",
	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")
		require("harpoon").setup({
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
		})
		vim.keymap.set("n", "<leader>h", mark.add_file)
		vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)
	end,
}
