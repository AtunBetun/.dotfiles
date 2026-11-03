return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			fuzzy = { implementation = "lua" },
			keymap = {
				["<C-n>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-y>"] = { "accept", "fallback" },
				["<C-Space>"] = { "show" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 250 },
			},
			sources = {
				default = { "lsp", "path", "snippets" },
			},
			signature = { enabled = true },
		},
	},
}
