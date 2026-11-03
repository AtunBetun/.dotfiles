require("custom.set")
require("custom.clipboard")
require("custom.remap")

vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1


vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.notify("lazy.nvim is missing; clone folke/lazy.nvim (stable) into " .. lazypath .. " before starting Neovim", vim.log.levels.ERROR)
	return
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ { import = "custom.plugins" } }, {
	install = { missing = vim.g.dotfiles_setup == true },
	checker = { enabled = false },
	change_detection = { notify = false },
})
