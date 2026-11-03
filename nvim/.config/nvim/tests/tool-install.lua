-- Run without plugins: nvim --headless -u NONE -l tests/tool-install.lua
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local specs = dofile(config .. "/lua/custom/plugins/lsp.lua")
local spec = specs[2]
local install_command
vim.api.nvim_create_user_command = function(name, callback)
	assert(name == "DotfilesToolsInstallSync")
	install_command = callback
end
local errors, exits = {}, {}
vim.api.nvim_err_writeln = function(message) table.insert(errors, message) end
vim.api.nvim_list_uis = function() return {} end
vim.cmd = function(command) table.insert(exits, command) end
vim.notify = function() end
local installed = true
local version = "1.0.0"
local refresh_mode, missing, installs = "success", false, 0
vim.wait = function(timeout, predicate)
	assert(timeout == 30000)
	return predicate()
end
package.loaded["mason-tool-installer"] = {
	setup = function() end,
	check_install = function(force, sync)
		assert(not force and sync)
		installs = installs + 1
	end,
}
package.loaded["mason-registry"] = {
	refresh = function(callback)
		if refresh_mode ~= "timeout" then
			callback(refresh_mode == "success")
		end
	end,
	get_package = function()
		if missing then error("Unavailable registry package") end
		return {
			is_installed = function() return installed end,
			get_installed_version = function() return version end,
		}
	end,
}
spec.config(nil, { ensure_installed = { { "example", version = "1.0.0" } } })
install_command()
assert(#errors == 0 and #exits == 0)
installed = false
install_command()
assert(#errors == 1 and exits[1] == "cquit 1")
assert(errors[1]:find("example is not installed", 1, true))
installed = true
version = "2.0.0"
install_command()
assert(#errors == 2 and exits[2] == "cquit 1")
assert(errors[2]:find("example does not match pinned 1.0.0", 1, true))
local successful_installs = installs
refresh_mode = "failure"
install_command()
assert(#errors == 3 and errors[3]:find("Registry refresh failed", 1, true))
assert(installs == successful_installs and exits[3] == "cquit 1")
refresh_mode = "timeout"
install_command()
assert(#errors == 4 and errors[4]:find("timed out after 30 seconds", 1, true))
assert(installs == successful_installs and exits[4] == "cquit 1")
refresh_mode, missing = "success", true
install_command()
assert(#errors == 5 and errors[5]:find("unavailable in the pinned registry", 1, true))
assert(installs == successful_installs and exits[5] == "cquit 1")
print("tool installation contract checks passed")
