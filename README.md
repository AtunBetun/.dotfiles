# Portable dotfiles

Zsh, Herdr TUI and modular Neovim for macOS, Amazon Linux 2 and Amazon Linux 2023. Mise deploys user configuration and selects pinned tools. Homebrew owns Mac applications. The only deployed scripts are `herdr-sessionizer` and `hherd`.

## Setup

Keep an existing SSH session open. Back up your live shell/editor/Herdr config, global mise config, Git config and link destinations outside this repository before cutover. Existing symlinks into this checkout change when you edit their sources.

Prerequisites: Git 2.36+, Bash, Zsh, curl, tar, gzip, unzip and a C compiler. Linux also needs native Clang/LLVM development libraries (Clang 9+; AL2 provides 11.1) for the parser CLI source build; AL2 additionally needs CMake 3.16+ and make for Neovim. Install `clang-devel llvm-devel` through your approved OS provisioning; `llvm-config --libdir` selects the compatible library, or set machine-local `LIBCLANG_PATH`. A newer Linuxbrew libclang can require a newer glibc and fail on AL2. This setup never runs sudo, upgrades the OS or changes your login shell. Preserve AxE/Builder Toolbox/Midway/WSSH setup.

Use the tested mise release, 2026.11.0. If another mise is installed, update that installation deliberately rather than adding a competing executable. The upstream installer supports a pinned release and checksum verification:

```sh
curl -fsSL -o install-mise.sh https://mise.run
# Review the script; follow mise's signed-installer verification for higher assurance.
MISE_VERSION=v2026.11.0 sh install-mise.sh
rm install-mise.sh
```

Run from this checkout, wherever it lives:

```sh
./setup --dry-run
./setup
mise run editor-setup
mise run check
```

`MISE_BIN=/path/to/mise ./setup` selects an explicit installation. Setup detects AL2, installs the selected profile from its lockfile before deployment, then links only declared targets. It refuses real-file conflicts rather than deleting or forcing them. Compare and back up a conflicting file before moving it aside. Existing mise overlays stay local; inspect them for obsolete runtime declarations.

AL2 deployment selects `mise.al2.toml`. For direct mise inspection/removal on AL2, use `mise -E al2 dot status` / `mise -E al2 dot unapply --dry-run`. Do not run an unqualified upstream deployment on AL2. `./setup` and `./check` select it automatically.

## Runtimes

`runtime/common.toml` owns Python, Go, Java, Rust, Herdr, fzf, jq, ripgrep, fd and Stylua. It selects native tree-sitter CLI on macOS and a source build on Linux because the published Linux binary requires newer glibc than AL2023. `runtime/config.toml` selects upstream Node and Neovim. AL2 uses Amazon RtxNode and source-built Neovim. AL2 Node 22.21.1 is an explicit exception to upstream 22.22.2; these pins are declarations, not automatic upgrades.

Both lockfiles record supported architecture artifacts/checksums where their backend provides them. Plugin/source builds pin the plugin or source release, but do not checksum every compiled output. Projects can override runtime defaults. Brazil dependency runtimes remain package-owned; no shared JAVA_HOME or PYTHONPATH is forced. Java LSP resolves the installed global editor JDK separately from the project's build JDK.

Interactive shells activate mise; both helpers use the installed global environment independently of the current project's config. Opening a picker/editor does not install missing tools. Change pins and regenerate locks deliberately, then test the changed tools. Do not uninstall unrelated existing versions automatically.

## Herdr

```sh
herdr
herdr-sessionizer                  # choose from ~/work, ~/projects or a Brazil workspace
herdr-sessionizer 'path with spaces'
hherd work-host
```

The picker is bound to `Ctrl-a f`; Herdr's native workspace picker remains `Ctrl-a w`. Optional extra search roots are colon-separated `DOTFILES_PROJECT_ROOTS` in machine-local shell config. `hherd` uses normal SSH authentication and server keybindings. No client/server restart or version update is hidden in these scripts.

## Neovim

Kickstart-inspired, not a distribution. Keep `init.lua`, `lua/custom/set.lua`, `remap.lua`, `clipboard.lua` and focused plugin files. Retained languages: Python, Java/Bemol, TypeScript/JavaScript, Go, Rust, Docker/Tailwind/web markup and Lua.

`mise run editor-setup` bootstraps pinned lazy.nvim, restores plugin commits, installs pinned Mason tools from a pinned registry snapshot and installs the selected parsers. Mason does not own Stylua, Rust's analyzer or rustfmt; mise owns those. Installation errors fail the setup instead of claiming success. Package installations inherit approved npm/pip network configuration; repair expired registry authentication rather than replacing corporate registries globally.

Normal editor startup performs no plugin/tool/parser installation. Use `NVIM_APPNAME=nvim-trial` with separate config/data/cache/state to trial changes without deleting your existing undo/history/plugin data. Work code review loads only with `DOTFILES_WORK=1` or available Brazil tooling.

## Clipboard

`cpwd` and shell `clipboard-copy` use pbcopy locally on Macs, a Wayland/X11 provider on desktops, or OSC 52 on an attached terminal. Headless remote hosts do not require xclip or X forwarding. No-client copies fail with a diagnostic. Neovim keeps native local providers and uses remote OSC 52 copy only; remote clipboard reads are disabled. Paste with Cmd-V/system paste.

Before cutover is accepted, verify from the actual Mac client to both AL2 and AL2023:

- `<leader>y` in Neovim and `cpwd` reach the Mac clipboard.
- Multiline text with tabs, Unicode and a trailing newline pastes correctly into the remote editor and shell.
- Herdr selection copy, detach/reattach and image paste work where used.

Use `hherd` / local `herdr --remote` for Herdr's desktop bridge. A successful OSC 52 escape-sequence check alone does not prove the laptop clipboard.

## Amazon and personal Git

Deployment adds a managed include block to your existing `.gitconfig`; it does not replace credential helpers, SSH routing, keys or certificates. Corporate remotes select your work identity; repositories under your personal GitHub account select personal identity. Unclassified repositories get an empty email and must configure one explicitly. Repositories mixing work/personal remotes need repository-local identity.

Personal HTTPS access retains GCM with `credentialStore=gpg`, backed by your initialized pass/GPG store. Configure the GCM helper locally where needed; a machine-specific glibc loader stays machine-local. Private keys, tokens, password stores and Midway material never enter this repository. Work GitFarm/GitLab access remains Midway SSH, not GCM.

Machine-specific shell additions live in `${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local.zsh`. This file is not deployed or committed.

## Mac applications

```sh
mise run mac-apps
mise run mac-update               # explicit app updates
```

The Mac-only Brewfile installs AeroSpace, Scroll Reverser and Caffeine plus native prerequisites. `macos/setup` preserves/migrates an existing AeroSpace config and seeds the checked-in config only when none exists. Review and copy your settings back to `macos/aerospace.toml` to share them; device-specific Scroll Reverser settings stay local.

Grant Accessibility in System Settings and enable each app's own Start at login setting. Existing choices are preserved, not overwritten. AeroSpace is beta/unnotarized and its cask removes quarantine: installation must comply with corporate-managed-device controls. No GUI app starts from `.zshrc`; no Homebrew cleanup removes unrelated packages.

## Recovery

Preview `mise dot unapply --dry-run` (add `-E al2` on AL2) while the manifest still exists. Unapply removes owned links and its Git include block, not your source files or unrelated configuration. Restore the saved original files/link destinations afterward. Removing a declaration alone does not remove an already deployed target.

Legacy tmux/test/workspace helper files were removed from this repository, not uninstalled from machines or stopped. Remove old live links only after checking their destinations and confirming they are obsolete. Never delete whole Neovim data directories or kill existing Herdr sessions as cleanup.

## Verification

Run `mise run check` after deployment and the editor setup. Permanent editor checks run without plugins:

```sh
nvim --headless -u NONE -l nvim/.config/nvim/tests/clipboard.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/tool-install.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/bemol.lua
```

Mac UI permissions, native app behavior and actual laptop clipboard round trips require a Mac session. They are not certified by Linux-only checks.
