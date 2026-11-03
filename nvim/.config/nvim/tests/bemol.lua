-- Run without plugins: nvim --headless -u NONE -l tests/bemol.lua
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local spec = dofile(config .. "/lua/custom/plugins/lsp.lua")[3]
local diagnostic, lsp = vim.diagnostic, vim.lsp
local attach
vim.api.nvim_create_autocmd = function(event, opts)
	assert(event == "LspAttach")
	attach = opts.callback
end
vim.api.nvim_create_augroup = function() return 1 end
vim.keymap.set = function() end
vim.diagnostic.config = function() end
vim.lsp.config = function() end
vim.lsp.enable = function() end
package.loaded["telescope.builtin"] = setmetatable({}, { __index = function() return function() end end })
package.loaded["blink.cmp"] = { get_lsp_capabilities = function() return {} end }
local clients = {}
vim.lsp.get_client_by_id = function(id) return clients[id] end
vim.api.nvim_buf_get_name = function(bufnr)
	assert(bufnr == 42)
	return "/workspace/src/Main.java"
end
vim.fs.find = function(_, opts)
	assert(opts.path == "/workspace/src")
	return { "/workspace/.bemol" }
end
local open = io.open
io.open = function(path)
	assert(path == "/workspace/.bemol/ws_root_folders")
	return {
		lines = function()
			local lines, index = { "/workspace/dependency", "/workspace/dependency", "" }, 0
			return function() index = index + 1; return lines[index] end
		end,
		close = function() end,
	}
end
for id = 1, 2 do
	clients[id] = {
		workspace_folders = {},
		notifications = {},
		supports_method = function(_, method) return method == "workspace/didChangeWorkspaceFolders" end,
		notify = function(self, method, params)
			assert(method == "workspace/didChangeWorkspaceFolders")
			table.insert(self.notifications, params)
		end,
	}
end
spec.config()
attach({ buf = 42, data = { client_id = 1 } })
attach({ buf = 42, data = { client_id = 2 } })
attach({ buf = 42, data = { client_id = 1 } })
for _, client in ipairs(clients) do
	assert(#client.workspace_folders == 1 and #client.notifications == 1)
	assert(client.workspace_folders[1].uri == vim.uri_from_fname("/workspace/dependency"))
	assert(#client.notifications[1].event.added == 1)
end
print("Bemol multi-client contract checks passed")
io.open = open
