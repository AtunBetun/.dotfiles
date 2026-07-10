return {
	"eltonsst/local-review.nvim",
	config = function()
		require("local_review").setup({
			keymap = "<leader>rc",
		})
	end,
}
