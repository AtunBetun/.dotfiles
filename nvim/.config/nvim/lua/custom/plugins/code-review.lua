return {
	url = "ssh://git.amazon.com:2222/pkg/NvimCodeReview",
	enabled = function()
		return vim.env.DOTFILES_WORK == "1" or vim.fn.executable("brazil") == 1
	end,
	opts = {
		exclude_patterns = { "*.md" },
	},
	config = function(_, opts)
		require("code_review").setup(opts)
	end,
	keys = {
		{ "<leader>cr", "<cmd>CodeReview<cr>", desc = "Code Review" },
		{ "<leader>cb", "<cmd>CodeReviewBrowse<cr>", desc = "Code Review (browse)" },
	},
}
