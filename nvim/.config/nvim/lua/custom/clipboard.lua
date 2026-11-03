local remote = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
local desktop = vim.fn.has("macunix") == 1 or vim.env.WAYLAND_DISPLAY ~= nil or vim.env.DISPLAY ~= nil

-- Local desktops keep Neovim's native provider detection.
if not remote and desktop then
	return
end

local function paste_unavailable()
	vim.notify("Remote clipboard reads are unavailable; use Cmd-V / terminal paste", vim.log.levels.WARN)
	return { {}, "v" }
end

local function copy(register)
	local osc52_copy = require("vim.ui.clipboard.osc52").copy(register)
	return function(lines, regtype)
		if #vim.api.nvim_list_uis() == 0 then
			vim.notify("Clipboard copy requires an attached OSC 52-capable terminal", vim.log.levels.WARN)
			return
		end
		osc52_copy(lines, regtype)
	end
end

vim.g.clipboard = {
	name = "OSC 52 copy only",
	copy = { ["+"] = copy("+"), ["*"] = copy("*") },
	paste = { ["+"] = paste_unavailable, ["*"] = paste_unavailable },
	cache_enabled = 0,
}
