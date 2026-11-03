-- Run without plugins: nvim --headless -u NONE -l tests/clipboard.lua
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local clipboard = config .. "/lua/custom/clipboard.lua"
local notices, copies = {}, {}
vim.notify = function(message)
	table.insert(notices, message)
end
local uis = {}
vim.api.nvim_list_uis = function()
	return uis
end
package.loaded["vim.ui.clipboard.osc52"] = {
	copy = function(register)
		return function(lines)
			table.insert(copies, { register = register, lines = lines })
		end
	end,
	paste = function()
		error("Clipboard reads must never query OSC 52")
	end,
}

vim.env.SSH_CONNECTION = "test"
dofile(clipboard)
assert(vim.g.clipboard.cache_enabled == 0)
local provider = vim.g.clipboard
assert(vim.deep_equal(provider.paste["+"](), { {}, "v" }))
provider.copy["+"]({ "marker" }, "v")
assert(#copies == 0 and #notices == 2)
uis = { { chan = 1 } }
provider.copy["+"]({ "tabs\tUnicode λ", "" }, "V")
assert(#copies == 1 and copies[1].register == "+")
assert(vim.deep_equal(copies[1].lines, { "tabs\tUnicode λ", "" }))

vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = nil
vim.env.DISPLAY = ":test"
vim.g.clipboard = nil
dofile(clipboard)
assert(vim.g.clipboard == nil, "Local native provider must remain automatic")
print("clipboard contract checks passed")
