return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local parsers = {
				"vimdoc",
				"javascript",
				"typescript",
				"tsx",
				"go",
				"gomod",
				"gowork",
				"dockerfile",
				"lua",
				"luadoc",
				"rust",
				"jsdoc",
				"bash",
				"python",
				"java",
				"json",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"query",
				"diff",
			}

			vim.api.nvim_create_user_command("DotfilesParsersInstall", function()
				assert(require("nvim-treesitter").install(parsers):wait(600000), "Parser installation failed; inspect :messages")
			end, { desc = "Install parsers for the retained language set" })

			local function treesitter_try_attach(buf, language)
				local loaded, error = vim.treesitter.language.add(language)
				if not loaded then
					vim.notify("Treesitter: " .. tostring(error), vim.log.levels.WARN)
					return
				end
				vim.treesitter.start(buf, language)

				local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil
				if has_indent_query then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end


			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match
					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					local installed_parsers = require("nvim-treesitter").get_installed("parsers")

					if vim.tbl_contains(parsers, language) and vim.tbl_contains(installed_parsers, language) then
						treesitter_try_attach(buf, language)
					end
				end,
			})

		end,
	},
}
