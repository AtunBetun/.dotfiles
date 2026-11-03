-- Run without plugins: nvim --headless -u NONE -l tests/tool-install.lua
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local spec = dofile(config .. "/lua/custom/plugins/lsp.lua")[2]
local tools = spec.opts.ensure_installed
local refresh_mode, install_mode, missing = "success", "success", false
local installs, packages = 0, {}
for _, tool in ipairs(tools) do
	packages[tool[1]] = {
		is_installed = function(self) return self.version ~= nil end,
		get_installed_version = function(self) return self.version end,
	}
end
vim.fn.stdpath = function() return config end
vim.uv.fs_stat = function() return {} end -- lazy is already bootstrapped in this harness.
vim.wait = function(_, predicate) return predicate() end
vim.cmd = {
	source = function() end,
	MasonToolsInstallSync = function()
		installs = installs + 1
		if install_mode == "error" then error("installer failed") end
		for _, tool in ipairs(tools) do
			packages[tool[1]].version = install_mode == "success" and tool.version or nil
		end
		if install_mode == "wrong-version" then packages[tools[1][1]].version = "wrong" end
	end,
	DotfilesParsersInstall = function() end,
}
package.loaded["lazy"] = { install = function() end, restore = function() end }
package.loaded["lazy.core.config"] = { plugins = {
	["mason-tool-installer.nvim"] = { opts = spec.opts, _ = { installed = true } },
} }
package.loaded["lazy.core.plugin"] = { values = function(plugin) return plugin.opts end }
package.loaded["mason-registry"] = {
	refresh = function(callback)
		if refresh_mode == "error" then error("refresh failed") end
		if refresh_mode ~= "timeout" then callback(refresh_mode == "success") end
	end,
	get_package = function(name)
		assert(not missing, "Unavailable registry package")
		return assert(packages[name])
	end,
}
local function setup_fails(message)
	local ok, failure = pcall(dofile, config .. "/setup.lua")
	assert(not ok and tostring(failure):find(message, 1, true), tostring(failure))
end
dofile(config .. "/setup.lua") -- fresh machine installs the entire real pin list.
dofile(config .. "/setup.lua") -- repeated setup validates the same pins.
for _, mode in ipairs({ "failure", "timeout", "error" }) do
	refresh_mode = mode
	local before = installs
	setup_fails(mode == "timeout" and "timed out" or "refresh failed")
	assert(installs == before)
end
refresh_mode, missing = "success", true
local before = installs
setup_fails("Unavailable registry package")
assert(installs == before)
missing, install_mode = false, "error"
setup_fails("installer failed")
install_mode = "partial"
setup_fails("is not installed")
install_mode = "wrong-version"
setup_fails("does not match pinned")
print("tool installation contract checks passed")
