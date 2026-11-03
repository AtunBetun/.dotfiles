# Modular Neovim

Kickstart-inspired configuration; retains separate settings, keymaps, clipboard and plugin modules. Requires Neovim 0.12 and the pinned runtime/tool setup in the repository root.

Run `mise run editor-setup` after dotfile deployment. It bootstraps pinned lazy.nvim, restores `lazy-lock.json`, installs the pinned Mason registry/tool set and selected syntax parsers. Startup never downloads missing dependencies. `:DotfilesToolsInstallSync` and `:DotfilesParsersInstall` explicitly provision the retained set.

Features: Blink completion, LSP/Bemol, Telescope, Oil, Fugitive/Gitsigns, Conform, Treesitter, Gruvbox and a minimal statusline. Languages: Python, Java/Bemol, TypeScript/JavaScript, Go, Rust, Docker/Tailwind/web markup and Lua. Amazon code review is gated by work tooling or `DOTFILES_WORK=1`.

Use `<leader>f` to format and `<leader>y` / `<leader>Y` to copy to the system clipboard. Remote paste uses Cmd-V/terminal paste; clipboard reads from the remote are disabled. Local desktops retain native provider detection.

Java's language server uses the installed global mise JDK, not the project's build JDK, and keeps project-hashed writable state under Neovim's cache directory. Mason paths derive from `stdpath('data')`; no machine-specific executable prefixes are committed.

Trial changes with separate `NVIM_APPNAME` and XDG directories. Preserve existing editor data and the lockfile; do not follow upstream recipes that delete all `~/.local/share/nvim` state.

See the root README for platform prerequisites, updates, recovery and clipboard acceptance checks.
