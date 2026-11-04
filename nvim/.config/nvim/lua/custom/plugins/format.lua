return {
	"stevearc/conform.nvim",
	lazy = false,
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		notify_on_error = true,
		format_on_save = function(bufnr)
			local filetype = vim.bo[bufnr].filetype
			local selected = {
				lua = true,
				python = true,
				java = true,
				rust = true,
				go = true,
				javascript = true,
				javascriptreact = true,
				typescript = true,
				typescriptreact = true,
				html = true,
				css = true,
				json = true,
				jsonc = true,
				markdown = true,
			}
			if not selected[filetype] then
				return
			end
			return { timeout_ms = 1000, lsp_format = "fallback" }
		end,
		formatters = {
			stylua = { command = "stylua" },
			black = { command = vim.fn.stdpath("data") .. "/mason/bin/black" },
			prettier = { command = vim.fn.stdpath("data") .. "/mason/bin/prettier" },
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			markdown = { "prettier" },
		},
	},
}
