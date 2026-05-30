local function bemol()
	local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
	local ws_folders_lsp = {}
	if bemol_dir then
		local file = io.open(bemol_dir .. "/ws_root_folders", "r")
		if file then
			for line in file:lines() do
				table.insert(ws_folders_lsp, line)
			end
			file:close()
		end
	end

	for _, line in ipairs(ws_folders_lsp) do
		vim.lsp.buf.add_workspace_folder(line)
	end
end

return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"black",
				"jdtls",
				"pyright",
				"ruff",
				"terraform-ls",
				"docker-language-server",
				"tailwindcss-language-server",
				"vtsls",
				"lua-language-server",
				"rust-analyzer",
				"smithy-language-server",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-jdtls",
			{ "j-hui/fidget.nvim", opts = {} },
			{ "folke/lazydev.nvim", opts = {} },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end

					bemol()
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = { min = vim.diagnostic.severity.WARN } },
				virtual_text = true,
			})

			local servers = {
				pyright = {},
				rust_analyzer = {},
				tailwindcss = {},
				dockerls = {},
				smithy_ls = {},
				vtsls = {
					on_init = function(client)
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end,
				},
				lua_ls = {
					cmd = { "/home/linuxbrew/.linuxbrew/bin/lua-language-server" },
					on_init = function(client)
						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
						})
					end,
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
			}

			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end
		end,
	},
}
