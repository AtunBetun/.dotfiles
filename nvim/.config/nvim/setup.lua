local data = vim.fn.stdpath("data")
local config = vim.fn.stdpath("config")
local lock = vim.json.decode(table.concat(vim.fn.readfile(config .. "/lazy-lock.json"), "\n"))
local lazy = data .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
    local result = vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazy }):wait()
    assert(result.code == 0, result.stderr)
    result = vim.system({ "git", "-C", lazy, "checkout", lock["lazy.nvim"].commit }):wait()
    assert(result.code == 0, result.stderr)
end
vim.opt.loadplugins = true
vim.g.dotfiles_setup = true
vim.cmd.source(config .. "/init.lua")
require("lazy").install({ wait = true, lockfile = true })
require("lazy").restore({ wait = true })
for name, plugin in pairs(require("lazy.core.config").plugins) do
    assert(plugin._.installed, "Plugin installation failed: " .. name)
end
local registry = require("mason-registry")
local refreshed
registry.refresh(function(success) refreshed = success end)
-- Native sync installation waits forever if registry refresh or package lookup fails.
assert(vim.wait(30000, function() return refreshed ~= nil end), "Mason registry refresh timed out after 30 seconds")
assert(refreshed, "Mason registry refresh failed")
local plugin = require("lazy.core.config").plugins["mason-tool-installer.nvim"]
local tools = require("lazy.core.plugin").values(plugin, "opts", false).ensure_installed
local packages = vim.tbl_map(function(tool) return registry.get_package(tool[1]) end, tools)
vim.cmd.MasonToolsInstallSync()
for index, tool in ipairs(tools) do
    local package = packages[index]
    assert(package:is_installed(), tool[1] .. " is not installed; inspect :MasonLog")
    assert(package:get_installed_version() == tool.version, tool[1] .. " does not match pinned " .. tool.version)
end
vim.cmd.DotfilesParsersInstall()
print("Editor plugins, language tools and parsers installed")
