-- Run without plugins: nvim --headless -u NONE -l tests/tool-install.lua
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
local spec = dofile(config .. "/lua/custom/plugins/lsp.lua")[2]
local tools = spec.opts.ensure_installed
local fixture_config = vim.fn.tempname()
vim.fn.mkdir(fixture_config, "p")
local lockfile = fixture_config .. "/lazy-lock.json"
local original_bytes = vim.fn.readfile(config .. "/lazy-lock.json", "b")
assert(vim.fn.writefile(original_bytes, lockfile, "b") == 0)
local original_lock = vim.json.decode(table.concat(original_bytes, "\n"))
local lazy_mode, checkout = "success", "different-commit"
local lazy_plugin = { name = "mason-tool-installer.nvim", opts = spec.opts, _ = { installed = true } }
local lazy_lock = { _loaded = false }
function lazy_lock.load()
	if lazy_lock._loaded then return end
	lazy_lock._loaded = true
	lazy_lock.lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile, "b"), "\n"))
end
local function update_lock()
	lazy_lock.load()
	lazy_lock.lock[lazy_plugin.name].commit = checkout
	assert(vim.fn.writefile({ vim.json.encode(lazy_lock.lock) }, lockfile, "b") == 0)
end
local function assert_original_lock()
	assert(vim.deep_equal(vim.fn.readfile(lockfile, "b"), original_bytes), "lazy-lock.json bytes changed")
end
local refresh_mode, install_mode, missing = "success", "success", false
local installs, packages = 0, {}
for _, tool in ipairs(tools) do
	packages[tool[1]] = {
		is_installed = function(self) return self.version ~= nil end,
		get_installed_version = function(self) return self.version end,
	}
end
vim.fn.stdpath = function() return fixture_config end
vim.uv.fs_stat = function() return {} end -- lazy is already bootstrapped in this harness.
vim.wait = function(_, predicate) return predicate() end
vim.cmd = {
	source = function()
		update_lock() -- init.lua may install missing plugins before explicit install.
		if lazy_mode == "source-error" then error("source failed") end
	end,
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
package.loaded["lazy"] = {
	install = function()
		update_lock() -- Lazy rewrites pins for already installed checkouts too.
		if lazy_mode == "install-error" then error("plugin install failed") end
	end,
	restore = function()
		assert_original_lock()
		lazy_lock.load()
		assert(vim.deep_equal(lazy_lock.lock, original_lock), "restore used overwritten cached pins")
		if lazy_mode == "dirty" then
			lazy_plugin._.tasks = { { has_errors = function() return true end } }
		else
			checkout = lazy_lock.lock[lazy_plugin.name].commit
		end
		update_lock()
		if lazy_mode == "restore-error" then error("plugin restore failed") end
	end,
}
package.loaded["lazy.manage.lock"] = lazy_lock
package.loaded["lazy.core.config"] = { plugins = { [lazy_plugin.name] = lazy_plugin } }
package.loaded["lazy.core.plugin"] = {
	values = function(plugin) return plugin.opts end,
	has_errors = function(plugin)
		for _, task in ipairs(plugin._.tasks or {}) do
			if task:has_errors() then return true end
		end
		return false
	end,
}
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
	assert_original_lock()
end
dofile(config .. "/setup.lua") -- fresh machine installs the entire real pin list.
dofile(config .. "/setup.lua") -- repeated setup validates the same pins.
assert(checkout == original_lock[lazy_plugin.name].commit, "existing checkout was not restored to pinned commit")
assert_original_lock()
for mode, message in pairs({ ["source-error"] = "source failed", ["install-error"] = "plugin install failed", ["restore-error"] = "plugin restore failed" }) do
	lazy_mode, checkout = mode, "different-commit"
	setup_fails(message)
end
lazy_mode, checkout = "dirty", "different-commit"
local before_dirty = installs
setup_fails("Plugin setup failed: " .. lazy_plugin.name)
assert(lazy_plugin._.installed, "dirty checkout should remain installed")
assert(checkout == "different-commit", "dirty checkout should not be overwritten")
assert(installs == before_dirty, "tool installation should not run after a plugin error")
lazy_plugin._.tasks, lazy_mode = nil, "success"
lazy_plugin._.installed = false
setup_fails("Plugin installation failed: " .. lazy_plugin.name)
lazy_plugin._.installed = true
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
local old_work, old_executable = vim.env.DOTFILES_WORK, vim.fn.executable
vim.env.DOTFILES_WORK = nil
vim.fn.executable = function() return 0 end
local private = dofile(config .. "/lua/custom/plugins/code-review.lua")
assert(private.url and type(private.enabled) == "function", "disabled private plugin must keep its spec and lock pin")
assert(not private.enabled(), "private plugin should be disabled on a personal machine")
vim.env.DOTFILES_WORK = "1"
assert(private.enabled(), "explicit work mode should enable private plugin")
vim.env.DOTFILES_WORK = nil
vim.fn.executable = function() return 1 end
assert(private.enabled(), "Brazil should enable private plugin")
vim.env.DOTFILES_WORK, vim.fn.executable = old_work, old_executable
assert_original_lock()
assert(vim.fn.delete(fixture_config, "rf") == 0)
print("tool installation contract checks passed")
