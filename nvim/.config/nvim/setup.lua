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
vim.cmd.DotfilesToolsInstallSync()
vim.cmd.DotfilesParsersInstall()
print("Editor plugins, language tools and parsers installed")
