function ColorMyPencils(color)
	color = color or "gruvbox"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				disable_background = true,
				styles = {
					italic = false,
				},
			})
			vim.cmd("colorscheme rose-pine")
			ColorMyPencils()
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},

	{ "ellisonleao/gruvbox.nvim", name = "gruvbox", priority = 1000, config = true, opts = ... },
}
