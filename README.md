# Dotfiles

Zsh, Herdr TUI and modular Neovim for MacBook Pros, AL2 and AL2023. Mise handles tools, packages and dotfile deployment. No Brewfile or custom setup/check wrappers.

## Set up a machine

Clone this repository, then run:

```sh
./init
```

`init` installs mise if absent, selects the OS, installs prerequisites, then runs the mise setup, editor setup and checks. AL2 uses Amazon RtxNode and a Neovim source build. AL2023 uses native DNF packages. Mac apps use mise's native cask support. AL2's one `yum install` command remains because mise has no built-in yum manager.

Requirements before bootstrap: Bash, curl, Git checkout and network access. OS packages may prompt for sudo. On a Mac, install Apple's Command Line Tools first; Intel Macs also need Homebrew because mise's native formula manager supports Apple Silicon only. On corporate machines keep AxE, Builder Toolbox, Midway and WSSH setup intact. The bootstrap does not rewrite SSH authentication or change the login shell.

Back up live config before applying. Mise refuses conflicting regular files; compare and move them aside yourself, never use blanket `--force`. Existing symlinks into this checkout reflect source edits immediately.

Native commands, from this checkout:

```sh
mise trust
mise dot apply --dry-run
mise run setup
mise run editor-setup
mise run check
```

Use `mise -E al2` for those commands on AL2. `init` selects it automatically. To preview the task graph without executing it, put the flag before the task: `mise -E al2 run --dry-run setup`.

## Tool versions

| File | What to change |
| --- | --- |
| `tools/common.toml` | Python, Go, Java, Rust, Herdr, fzf, jq, fd, ripgrep, Stylua, parser CLI |
| `tools/default/config.toml` | Mac/AL2023 Node and Neovim |
| `tools/al2/config.toml` | AL2 Node and Neovim backends/versions |
| Each profile's `mise.lock` | Generated versions, artifact URLs/checksums where supported |

`tools/default/common.toml` and `tools/al2/common.toml` link to the single shared file. The directory is called `tools`, not `mise`: `mise/config.toml` would be auto-discovered as project config and mix the platform definitions.

Defaults: Python 3.12.16, Go 1.25.5, Corretto Java 21.0.13, Rust 1.90.0, Herdr 0.9.5, Neovim 0.12.6. Node is 22.22.2 on Mac/AL2023 and 22.21.1 through RtxNode on AL2. Projects can select other versions in their own `mise.toml`.

No downloads/upgrades occur during shell/editor startup. `mise run install` installs the selected pinned profile before replacing live config. Linux builds the parser CLI against native Clang/LLVM because the published binary needs newer glibc than AL2023. Native `clang-devel`/`llvm-devel` supply the compatible library; `init` gets it from `llvm-config`.

## Herdr helpers

Only two scripts are deployed:

```sh
herdr-sessionizer 'some/project'   # open/focus this directory
herdr-sessionizer                  # pick beneath the current directory
hherd work-host                    # attach using normal SSH
```

No guessed project roots, usernames or workspace paths. The picker searches three levels under the current directory. It supports spaces; newline-containing names are outside its documented shortcut. Herdr binds it to `Ctrl-a f`; the native workspace picker is `Ctrl-a w`.

`hherd` uses session `main`, or the explicit `TE` value when set, and server-side bindings. Neither helper updates or restarts servers. Both use mise's installed global tools, independent of the current project's configuration.

## Git

Default identity is Alberto De Saint Malo, `adesain@amazon.com`. No remote-URL routing and no blank email override.

Set personal identity explicitly in a personal repository:

```sh
git config --local user.email beto7299@gmail.com
```

Existing personal repository-local GCM/pass/GPG settings remain local. Shared dotfiles do not replace credential helpers or distribute host-specific glibc loaders. Keys, tokens, password stores and Midway certificates stay outside Git.

Deployment manages a small block in your existing `.gitconfig`, preserving surrounding settings. If you pasted the previous routing config directly into that file, remove the appended routing block; keep the original work identity and credential settings.

## Neovim

Kickstart-inspired, retaining separate `set.lua`, `remap.lua`, `clipboard.lua` and focused plugin files. Supports Python, Java/Bemol, TypeScript/JavaScript, Go, Rust, Docker/Tailwind/web markup and Lua.

`mise run editor-setup` installs locked plugins, pinned Mason tools and parsers. Mason pins are in `lua/custom/plugins/lsp.lua`; plugin commits are in `lazy-lock.json`. Installation errors fail setup. Normal startup installs nothing. Java LSP selects the global editor JDK without changing the project's Java environment.

Trial changes with separate `NVIM_APPNAME`/XDG directories; do not delete your editor's data/undo history.

## Clipboard

Local Macs use native copy/paste; desktop Linux uses Wayland/X11 providers. Remote Neovim and shell copy use OSC 52 through an attached terminal. Use Cmd-V/system paste into the remote; no remote clipboard reads.

`cpwd` copies the working directory. `<leader>y` / `<leader>Y` copy from Neovim. Check both directions, multiline/Unicode text and Herdr selection/image paste from the actual Mac client to AL2 and AL2023. Escape-sequence tests do not certify the laptop clipboard.

## Mac apps

AeroSpace, Scroll Reverser and Caffeine are declared in `[bootstrap.packages]`:

```sh
mise bootstrap packages apply --dry-run
mise bootstrap packages apply
mise bootstrap packages upgrade
```

Existing apps are adopted only when compatible; Homebrew-owned apps remain Homebrew-owned. Mise's formula installer skips Intel Macs: provision GCM/GnuPG/pass/CMake through existing Homebrew there. Casks work on both Mac architectures. No pruning removes unrelated apps.

AeroSpace config is seeded only if absent, preserving its existing supported location. Grant Accessibility in System Settings and enable each app's own Start at login. Device-specific Scroll Reverser preferences stay local. AeroSpace's cask removes quarantine; respect corporate-device controls.

## Recovery and checks

Preview `mise dot unapply --dry-run` (add `-E al2` on AL2), then restore backed-up files/link destinations. Unapply removes owned links and the managed Git include; source files and unrelated settings remain.

```sh
nvim --headless -u NONE -l nvim/.config/nvim/tests/clipboard.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/tool-install.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/bemol.lua
```

Mac GUI permissions and actual laptop clipboard round trips require a Mac session. Linux-only verification cannot certify them.
