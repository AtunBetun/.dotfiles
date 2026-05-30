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
autoload -Uz compinit && compinit -C

# =====================
# PATH SETUP
# =====================
export PATH="$HOME/.local/bin:$HOME/.local/share/nvim/mason/bin:/usr/local/go/bin:/usr/local/sbin:$HOME/.local/scripts:$HOME/.dotfiles/scripts:$PATH"
export PATH="$PATH:$HOME/.toolbox/bin"
export GOPROXY=direct

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

alias ls="ls --color=auto"
alias l="ls -lah"
alias ll="ls -lh"
alias la="ls -lAh"
alias v="nvim ."
alias c="claude --dangerously-skip-permissions"
alias cpwd="pwd | xclip -selection clipboard"
alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'

# =====================
# FZF
# =====================
source <(fzf --zsh)

# =====================
# BASH COMPLETION SUPPORT
# =====================
autoload -U +X bashcompinit && bashcompinit
command -v aws_completer &>/dev/null && complete -C aws_completer aws

# =====================
# MISE SETUP
# =====================
eval "$(mise activate zsh)"

# =====================
# AMAZON
# =====================
alias bb=brazil-build
alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use -p'
alias bwscreate='bws create -n'
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'
alias br='brazil-recursive-cmd brazil-build --allPackages'


[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
export JAVA_HOME=$(dirname $(dirname $(realpath /usr/bin/java)))
export PATH=$JAVA_HOME/bin:$PATH

export AWS_EC2_METADATA_DISABLED=true

# =====================
# TOOLS
# =====================

# Syncthing
if command -v syncthing &>/dev/null && ! pgrep -x syncthing > /dev/null; then
    nohup bash -c 'while true; do syncthing --no-browser --no-restart; sleep 5; done' > ~/.syncthing.log 2>&1 &
fi
alias st-status="pgrep -a syncthing"
alias st-stop="pkill syncthing"
alias st-start="nohup bash -c 'while true; do syncthing --no-browser --no-restart; sleep 5; done' > ~/.syncthing.log 2>&1 &"
alias st-log="tail -f ~/.syncthing.log"

# AIM CLI
export PATH="$HOME/.aim/mcp-servers:$PATH"

# Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

source <(entire completion zsh)
