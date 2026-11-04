# =====================
# PROMPT (gruvbox)
# =====================
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b%u'
zstyle ':vcs_info:git:*' unstagedstr ' %F{167}*%F{132}'
zstyle ':vcs_info:git:*' check-for-changes true
setopt PROMPT_SUBST

_dotfiles_prompt_arch=$(uname -m)
PROMPT=$'%F{223}%n@%M%f %F{109}[${_dotfiles_prompt_arch}]%f %F{214}%~%f %F{132}${vcs_info_msg_0_}%f
%F{208}$%f '

# =====================
# HISTORY
# =====================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# =====================
# COMPLETIONS (must be before tools that use compdef)
# =====================
autoload -Uz compinit
# Recheck completion definitions and permissions once a day.
_dotfiles_compdump="${ZDOTDIR:-$HOME}/.zcompdump"
_dotfiles_old_compdump=("${_dotfiles_compdump}"(N.mh+24))
if [[ ! -f $_dotfiles_compdump ]] || (( $#_dotfiles_old_compdump )); then
    compinit
else
    compinit -C
fi
unset _dotfiles_compdump _dotfiles_old_compdump

# =====================
# PATH SETUP
# =====================
typeset -U path PATH
path=("$HOME/.local/bin" $path)
for _dotfiles_bin in "$HOME/.toolbox/bin" "$HOME/.bun/bin" "$HOME/.opencode/bin"; do
    [[ -d $_dotfiles_bin ]] && path=("$_dotfiles_bin" $path)
done
unset _dotfiles_bin
if [[ ${DOTFILES_WORK:-0} == 1 ]] || command -v brazil &>/dev/null; then
    [[ -d $HOME/.aim/mcp-servers ]] && path=("$HOME/.aim/mcp-servers" $path)
fi
if [[ -z ${HOMEBREW_PREFIX:-} || -z ${HOMEBREW_CELLAR:-} || -z ${HOMEBREW_REPOSITORY:-} ]] && command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
fi
export EDITOR=nvim VISUAL=nvim
[[ -t 0 ]] && export GPG_TTY="$(tty)"

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
# Wait 100 ms for escape sequences, instead of the default 400 ms.
KEYTIMEOUT=10
bindkey -M viins '^S' history-incremental-search-forward
# Allow Backspace across the point where insert mode was entered.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

# Terminals send different Home/End sequences; keep them in the current mode.
for _dotfiles_keymap in viins vicmd; do
    bindkey -M "$_dotfiles_keymap" $'\e[H' beginning-of-line
    bindkey -M "$_dotfiles_keymap" $'\eOH' beginning-of-line
    bindkey -M "$_dotfiles_keymap" $'\e[1~' beginning-of-line
    bindkey -M "$_dotfiles_keymap" $'\e[F' end-of-line
    bindkey -M "$_dotfiles_keymap" $'\eOF' end-of-line
    bindkey -M "$_dotfiles_keymap" $'\e[4~' end-of-line
done
unset _dotfiles_keymap
bindkey -M viins $'\e[3~' delete-char
bindkey -M vicmd $'\e[3~' vi-delete-char

# Native ZLE hooks preserve other shell integrations.
if [[ -t 1 && $TERM != dumb ]]; then
    autoload -Uz add-zle-hook-widget
    _dotfiles_vi_cursor() {
        case $KEYMAP in
            vicmd) printf '\e[2 q' ;; # Block in command mode.
            *)     printf '\e[6 q' ;; # Beam in insert mode.
        esac
    }
    _dotfiles_vi_cursor_reset() { printf '\e[0 q'; }
    add-zle-hook-widget line-init _dotfiles_vi_cursor
    add-zle-hook-widget keymap-select _dotfiles_vi_cursor
    add-zle-hook-widget line-finish _dotfiles_vi_cursor_reset
fi

if [[ $OSTYPE == darwin* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias l="ls -lah"
alias ll="ls -lh"
alias la="ls -lAh"
alias v="nvim ."
alias c="claude --dangerously-skip-permissions"
alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'


# =====================
# MISE SETUP
# =====================
# Shims select project tool versions when commands run, without a prompt hook.
# Use `mise exec -- command` when a command also needs mise's environment variables.
_dotfiles_mise_shims="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"
[[ -d $_dotfiles_mise_shims ]] && path=("$_dotfiles_mise_shims" $path)
unset _dotfiles_mise_shims
# =====================
# FZF
# =====================
if [[ -t 0 && -t 1 ]] && (( $+functions[compdef] )) && command -v fzf &>/dev/null; then
    # Use the installed shell scripts without starting fzf through a mise shim.
    if [[ -r $HOME/.fzf/shell/completion.zsh && -r $HOME/.fzf/shell/key-bindings.zsh ]]; then
        source "$HOME/.fzf/shell/completion.zsh"
        source "$HOME/.fzf/shell/key-bindings.zsh"
    else
        source <(fzf --zsh)
    fi
fi
# Keep fzf's Ctrl-R binding in both vi modes when its integration is loaded.
if (( ! ${+widgets[fzf-history-widget]} )); then
    bindkey -M viins '^R' history-incremental-search-backward
    bindkey -M vicmd '^R' redo
fi

# =====================
# BASH COMPLETION SUPPORT
# =====================
if command -v aws_completer &>/dev/null; then
    autoload -Uz bashcompinit
    bashcompinit
    complete -C aws_completer aws
fi


# =====================
# AMAZON
# =====================
if [[ ${DOTFILES_WORK:-0} == 1 ]] || command -v brazil &>/dev/null; then
    alias bb='brazil-build'
    alias bba='brazil-build apollo-pkg'
    alias bre='brazil-runtime-exec'
    alias brc='brazil-recursive-cmd'
    alias brp='brazil-recursive-cmd-parallel'
    alias bws='brazil ws'
    alias bwsuse='bws use -p'
    alias bwscreate='bws create -n'
    alias bbr='brc brazil-build'
    alias bball='brc --allPackages'
    alias bbb='brc --allPackages brazil-build'
    alias bbra='bbr apollo-pkg'
    alias br='brazil-recursive-cmd-parallel --allPackages -- brazil-build'
    export AWS_EC2_METADATA_DISABLED=true
fi

if (( $+functions[compdef] )); then
    [[ -s $HOME/.bun/_bun ]] && source "$HOME/.bun/_bun"
    # Search for the optional CLI and load its completion only when requested.
    _dotfiles_entire_completion_lazy() {
        command -v entire &>/dev/null || return
        source <(entire completion zsh) || return
        local completion=${_comps[entire]}
        [[ -n $completion && $completion != _dotfiles_entire_completion_lazy ]] || return 1
        "$completion" "$@"
    }
    compdef _dotfiles_entire_completion_lazy entire
fi
[[ -r ${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local.zsh ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local.zsh"
true
