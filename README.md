# Dotfiles

Zsh, Herdr TUI and modular Neovim for MacBook Pros, AL2 and AL2023. Mise handles tools, packages and dotfile deployment. No Brewfile or custom setup/check wrappers.

## Set up a machine

Clone this repository, then run:

```sh
./init
```

`init` selects the OS and installs mise v2026.11.0 only if absent. It loads the manifest to enforce mise's minimum version before installing prerequisites, then runs the native mise setup, editor setup and checks. Managed mise profiles enable automatic mise self-update; an existing older version may update when mise runs. Update a corporate-managed installation through its approved channel. AL2 uses native mise archive downloads of Amazon-compatible Node binaries and a pinned Neovim source build; no legacy runtime plugins or wrappers. AL2023 uses native DNF packages. Mac apps use mise's native cask support. AL2's one `yum install` command remains because mise has no built-in yum manager.

The bootstrap prints the selected OS, profile, checkout and mise version, then shows native package status, package commands and the selected profile's tool versions before installation. Its plain-text progress bar counts completed stages, not elapsed time: each stage reports started, done or failed, followed by a summary. Native installer output and task timings remain visible, including sudo prompts. A failed command stops setup at that stage and preserves its exit code.

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

`tools/default` is the Mac/AL2023 source profile; `tools/al2` is the AL2 source profile. Setup installs from the selected profile, then links its config and lock into the global mise config directory (`~/.config/mise` by default; honors `XDG_CONFIG_HOME`/`MISE_CONFIG_DIR`). Their `common.toml` links share `tools/common.toml`. The directory is called `tools`, not `mise`: `mise/config.toml` would be auto-discovered as project config and mix the platform definitions.

Defaults: Python 3.12.16, Go 1.25.5, Corretto Java 21.0.13, Rust 1.90.0, Herdr 0.9.5, Neovim 0.12.6. Node is 22.22.2 on Mac/AL2023 and 22.21.1 on AL2. AL2's native archive backends download Amazon-compatible Node binaries and Neovim source pinned to `022946c802832f938398dfae34b3f277ca9509d4`; Neovim builds against the host libc, and build failures fail installation. Artifact URLs and checksums live in the profile's lockfile. Projects can select other versions in their own `mise.toml`.

Pinned tools and editor plugins do not download or upgrade during shell/editor startup. Mise may update its own binary when invoked, subject to its self-update check interval (default: 7 days). `mise run install` installs the selected pinned profile before replacing live config. Linux builds the parser CLI against native Clang/LLVM because the published binary needs newer glibc than AL2023. Native `clang-devel`/`llvm-devel` supply the compatible library; `init` gets it from `llvm-config`.

Zsh uses mise's shims directory on `PATH` instead of `mise activate`. Tool versions resolve when commands run, without running mise at startup or at every prompt. Project environment variables are not exported into the interactive shell: use `mise exec -- command` for commands that need them. Fzf loads the standard `~/.fzf/shell` scripts when installed, falling back to `fzf --zsh` otherwise; the fallback invokes mise when fzf is a shim.

Fzf keeps Ctrl-R for history search and Alt-C for directory selection in both vi modes. On macOS, setup seeds Ghostty's config with `keybind = alt+c=esc:c` if the file is absent. Add that line to an existing Ghostty config to enable Option-C, then reload it with Cmd-Shift-comma.

## Herdr helpers

Setup links only two scripts into `~/.local/bin`. To deploy just those links from this checkout, run `mise dot apply "$HOME/.local/bin/herdr-sessionizer" "$HOME/.local/bin/hherd"` (add `-E al2` on AL2):

```sh
herdr-sessionizer 'some/project'   # open/focus this directory
herdr-sessionizer                  # pick from home, work, personal, and workplace
hherd work-host                    # attach using normal SSH
```

Workspace names use the directory's final component: `/workplace/adesain/GwP` becomes `GwP`, while its working directory remains the full path. Selecting an existing name reuses that workspace; existing full-path labels are shortened when reopened.

The picker lists immediate child directories of `~/`, `~/work`, `~/personal`, `~/workplace`, and `/workplace/$(id -un)` when those roots exist. For each workplace child with a `src` directory, it also lists the directories directly inside `src`, as the older sessionizer did. It supports spaces; newline-containing names are outside its documented shortcut. Herdr binds it to `Ctrl-a f`. In a local Herdr client, `Ctrl-a s` (also `Ctrl-a w`) opens native workspace navigation across Local and saved SSH machines: use `j`/`k` or Up/Down to select a workspace and Enter to switch. Within that navigation view, `h`/`l` move between panes horizontally and Ctrl-J/Ctrl-K move vertically. Add another SSH machine with `herdr machine add HOST`. The separate `hherd HOST` client attaches to one remote session; use the local multi-machine client for switching between local and remote workspaces.

`hherd` uses session `main`, or the explicit `TE` value when set, and server-side bindings. It adds no custom install, update or restart logic. Native Herdr remote may prompt to install or update the remote binary, or stop an incompatible server; those prompts default to no. Accepting a server stop can interrupt running sessions and their processes. Both helpers use mise's installed global tools, independent of the current project's configuration.

## Git

Default identity is Alberto De Saint Malo, `adesain@amazon.com`. No remote-URL routing and no blank email override.

Set personal identity explicitly in a personal repository:

```sh
git config --local user.email beto7299@gmail.com
```

On Mac, mise's native HTTP backend installs Git Credential Manager (GCM) 3.0.2 from its [portable binary archives](https://github.com/git-ecosystem/git-credential-manager/releases/tag/v3.0.2), with fixed URLs and SHA-256 checksums for Intel and Apple Silicon. It does not run `configure` or change credential helpers. The pkg cask is deliberately excluded: its [postinstall script](https://github.com/git-ecosystem/git-credential-manager/blob/v3.0.2/build/macos/installer/scripts/postinstall) runs `configure`, which [changes user-level Git configuration](https://github.com/git-ecosystem/git-credential-manager/blob/v3.0.2/docs/usage.md#configureunconfigure).

Existing personal repository-local GCM/pass/GPG settings remain local; configure personal credential helpers explicitly with `git config --local`, not `git credential-manager configure`. Shared Git config does not replace credential helpers or distribute host-specific glibc loaders. Keys, tokens, password stores and Midway certificates stay outside Git.

Deployment manages a small block in your existing `.gitconfig`, preserving surrounding settings. If you pasted the previous routing config directly into that file, remove the appended routing block; keep the original work identity and credential settings.

## Neovim

Kickstart-inspired, retaining separate `set.lua`, `remap.lua`, `clipboard.lua` and focused plugin files. Supports Python, Java/Bemol, TypeScript/JavaScript, Go, Rust, Docker/Tailwind/web markup and Lua.

`mise run editor-setup` installs locked plugins, pinned Mason tools and parsers. Mason pins are in `lua/custom/plugins/lsp.lua`; plugin commits are in `lazy-lock.json`. Installation errors fail setup. Normal startup installs nothing. Java LSP selects the global editor JDK without changing the project's Java environment.

On Amazon machines, npm `E401` during editor setup can mean expired CodeArtifact credentials. Refresh them with `harmony npm`, then rerun `./init`; it retains the corporate registry. See [CodeArtifact authentication guidance](https://docs.hub.amazon.dev/docs/gitlab/user-guide/howto/codeartifact/#troubleshooting-the-harmony-cli-installation).

Trial changes with separate `NVIM_APPNAME`/XDG directories; do not delete your editor's data/undo history.

## Clipboard

Local Macs use native copy/paste; desktop Linux uses Wayland/X11 providers. Remote Neovim copy uses OSC 52 through an attached terminal. Use Cmd-V/system paste into the remote; no remote clipboard reads.

`<leader>y` / `<leader>Y` copy from Neovim. Check both directions, multiline/Unicode text and Herdr selection/image paste from the actual Mac client to AL2 and AL2023. Escape-sequence tests do not certify the laptop clipboard.

## Mac apps

AeroSpace, Scroll Reverser and Caffeine are declared in `[bootstrap.packages]`:

```sh
mise bootstrap packages apply --dry-run
mise bootstrap packages apply
mise bootstrap packages upgrade
```

Existing apps are adopted only when compatible. Mise recognizes Apple Silicon Homebrew-owned casks, but does not detect Intel Homebrew's `/usr/local/Caskroom`; Intel apps may be adopted or cause a compatibility conflict. Mise's formula installer skips Intel Macs: provision GnuPG/pass/CMake through existing Homebrew there. GCM's portable archives and app casks support both Mac architectures. No pruning removes unrelated apps.

The default mise environment appends `{{ system_brew_prefix }}/bin` after managed tool paths. Native package commands such as `pass` and `gpg` become available without replacing pinned Node/Python executables. Intel Homebrew binaries remain available through the shell's existing `brew shellenv` setup.

AeroSpace config is seeded only if absent, preserving its existing supported location. Grant Accessibility in System Settings and enable each app's own Start at login. Device-specific Scroll Reverser preferences stay local. AeroSpace's cask removes quarantine; respect corporate-device controls.

## Recovery and checks

Follow [the cleanup plan](cleanup-plan.md) before retiring old dotfiles. Preserve the existing recovery backup, credentials, SSH/GPG/password stores, Neovim undo/history/Mason state and Herdr sessions. Back up the live mise and Git configs plus the actual targets of affected symlinks. Quarantine confirmed unused Oh My Zsh and tmux plugin directories rather than deleting them; remove only dotfile-owned obsolete links and the legacy `dotnet`, `node`, `poetry` and `tmux` mise plugin registrations, not unrelated tools or project-required Python versions.

Relocate the backed-up regular mise global config before native deployment; never force a conflict. After cleanup, run `./init`, inspect deployment status and the two helper links, check effective Git emails, and confirm editor setup and preserved state.

Preview `mise dot unapply --dry-run` (add `-E al2` on AL2), then restore backed-up files, recorded symlink destinations and quarantined directories without overwriting newer user changes. Unapply removes owned links and the managed Git block; source files and unrelated settings remain. Keep both recovery backups until the installed setup and preserved state have been checked.

```sh
nvim --headless -u NONE -l nvim/.config/nvim/tests/clipboard.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/tool-install.lua
nvim --headless -u NONE -l nvim/.config/nvim/tests/bemol.lua
```

Mac GUI permissions and actual laptop clipboard round trips require a Mac session. Linux-only verification cannot certify them.
