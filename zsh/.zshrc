# =====================
# PROMPT (gruvbox)
# =====================
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b%u'
zstyle ':vcs_info:git:*' unstagedstr ' %F{167}*%F{132}'
zstyle ':vcs_info:git:*' check-for-changes true
setopt PROMPT_SUBST

PROMPT=$'%F{223}%n%f %F{214}%~%f %F{132}${vcs_info_msg_0_}%f
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
compinit -C

# =====================
# PATH SETUP
# =====================
typeset -U path PATH
path=("$HOME/.local/bin" $path)
for _dotfiles_bin in "$HOME/.toolbox/bin" "$HOME/.bun/bin" "$HOME/.opencode/bin"; do
    [[ -d $_dotfiles_bin ]] && path=("$_dotfiles_bin" $path)
done
unset _dotfiles_bin
command -v brew &>/dev/null && eval "$(brew shellenv)"
export EDITOR=nvim VISUAL=nvim
[[ -t 0 ]] && export GPG_TTY="$(tty)"

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

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
command -v mise &>/dev/null && eval "$(mise activate zsh)"
# =====================
# FZF
# =====================
if (( $+functions[compdef] )) && command -v fzf &>/dev/null; then
    source <(fzf --zsh)
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
    [[ -d $HOME/.aim/mcp-servers ]] && path=("$HOME/.aim/mcp-servers" $path)
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
    command -v entire &>/dev/null && source <(entire completion zsh)
fi
[[ -r ${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local.zsh ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/local.zsh"
true
