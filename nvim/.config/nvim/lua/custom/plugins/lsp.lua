local function bemol(bufnr, client)
	if not client or not client:supports_method("workspace/didChangeWorkspaceFolders") then
		return
	end
	local directory = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
	local bemol_dir = vim.fs.find({ ".bemol" }, { path = directory, upward = true, type = "directory" })[1]
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

	client.workspace_folders = client.workspace_folders or {}
	local known, added = {}, {}
	for _, folder in ipairs(client.workspace_folders) do
		known[folder.uri] = true
	end
	for _, line in ipairs(ws_folders_lsp) do
		if line ~= "" then
			local uri = vim.uri_from_fname(line)
			if not known[uri] then
				local folder = { uri = uri, name = line }
				table.insert(client.workspace_folders, folder)
				table.insert(added, folder)
				known[uri] = true
			end
		end
	end
	if #added > 0 then
		client:notify("workspace/didChangeWorkspaceFolders", { event = { added = added, removed = {} } })
	end
end

return {
	{
		"williamboman/mason.nvim",
		opts = {
			PATH = "skip",
			-- JDTLS download timestamps belong to the registry snapshot, not just the tool version.
			registries = { "github:mason-org/mason-registry@2026-06-11-hearty-test" },
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			run_on_start = false,
			auto_update = false,
			ensure_installed = {
				{ "black", version = "26.5.1" },
				{ "jdtls", version = "v1.58.0" },
				{ "pyright", version = "1.1.410" },
				{ "prettier", version = "3.8.3" },
				{ "gopls", version = "v0.22.0" },
				{ "dockerfile-language-server", version = "0.15.0" },
				{ "tailwindcss-language-server", version = "0.14.29" },
				{ "vtsls", version = "0.3.0" },
				{ "lua-language-server", version = "3.18.2" },
				{ "html-lsp", version = "4.10.0" },
				{ "css-lsp", version = "4.10.0" },
				{ "json-lsp", version = "4.10.0" },
			},
		},
		config = function(_, opts)
			local installer = require("mason-tool-installer")
			installer.setup(opts)
			vim.api.nvim_create_user_command("DotfilesToolsInstallSync", function()
				local function fail(errors)
					vim.api.nvim_err_writeln("Editor tool installation failed:\n" .. table.concat(errors, "\n") .. "\nInspect :MasonLog")
					if #vim.api.nvim_list_uis() == 0 then
						vim.cmd("cquit 1")
					end
				end
				local registry = require("mason-registry")
				local refreshed, refresh_success = false, false
				local started, refresh_error = pcall(registry.refresh, function(success)
					refreshed, refresh_success = true, success
				end)
				if not started then
					fail({ "Registry refresh failed: " .. tostring(refresh_error) })
					return
				end
				if not vim.wait(30000, function() return refreshed end) or not refresh_success then
					fail({ refreshed and "Registry refresh failed" or "Registry refresh timed out after 30 seconds" })
					return
				end
				local errors = {}
				for _, tool in ipairs(opts.ensure_installed) do
					local found = pcall(registry.get_package, tool[1])
					if not found then
						table.insert(errors, tool[1] .. " is unavailable in the pinned registry")
					end
				end
				if #errors > 0 then
					fail(errors)
					return
				end
				local ok, failure = pcall(installer.check_install, false, true)
				if not ok then
					table.insert(errors, tostring(failure))
				end
				for _, tool in ipairs(opts.ensure_installed) do
					local found, package = pcall(registry.get_package, tool[1])
					if not found or not package:is_installed() then
						table.insert(errors, tool[1] .. " is not installed")
					elseif package:get_installed_version() ~= tool.version then
						table.insert(errors, tool[1] .. " does not match pinned " .. tool.version)
					end
				end
				if #errors > 0 then
					fail(errors)
					return
				end
				vim.notify("All pinned Mason editor tools are installed")
			end, { desc = "Install pinned tools and fail on partial installation" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-jdtls",
			"saghen/blink.cmp",
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
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
						end, "[T]oggle Inlay [H]ints")
					end

					bemol(event.buf, client)
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "if_many",
					header = "",
					prefix = "",
				},
				underline = { severity = { min = vim.diagnostic.severity.WARN } },
				virtual_text = true,
			})


			local servers = {
				pyright = {},
				rust_analyzer = {},
				tailwindcss = {},
				dockerls = {},
				gopls = {},
				html = {},
				cssls = {},
				jsonls = {},
				vtsls = {
					on_init = function(client)
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end,
				},
				lua_ls = {
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

			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"
			local commands = {
				pyright = { "pyright-langserver", "--stdio" },
				rust_analyzer = { "rust-analyzer" },
				tailwindcss = { "tailwindcss-language-server", "--stdio" },
				dockerls = { "docker-langserver", "--stdio" },
				gopls = { "gopls" },
				html = { "vscode-html-language-server", "--stdio" },
				cssls = { "vscode-css-language-server", "--stdio" },
				jsonls = { "vscode-json-language-server", "--stdio" },
				vtsls = { "vtsls", "--stdio" },
				lua_ls = { "lua-language-server" },
			}
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			for name, config in pairs(servers) do
				config.cmd = commands[name]
				if name ~= "rust_analyzer" then
					config.cmd[1] = mason_bin .. config.cmd[1]
				end
				config.capabilities = capabilities
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end
		end,
	},
}
