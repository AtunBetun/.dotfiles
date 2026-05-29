
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh"

# =====================
# CORE OH-MY-ZSH SETUP
# =====================
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_UPDATE="true"
ZSH_THEME="crcandy"
plugins=(git docker)

# Source Oh-My-Zsh once
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# =====================
# PATH SETUP
# =====================
export PATH="$HOME/.local/bin:$HOME/.bx_scripts/bin:$HOME/.local/share/nvim/mason/bin:/usr/local/go/bin:/usr/local/sbin:~/.local/scripts:/opt/nvim-linux64/bin:/home/bxuser/bin:$HOME/.dotfiles/scripts:$PATH"
export PATH="$PATH:$HOME/.toolbox/bin"
export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
export GOPROXY=direct

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

alias v="nvim ."
alias cpwd="pwd | xclip -selection clipboard"
alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'

# =====================
# FZF
# =====================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(~/.local/share/mise/installs/fzf/0.67.0/fzf --zsh)

# =====================
# BASH COMPLETION SUPPORT
# =====================
autoload -U +X bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# =====================
# MISE SETUP
# =====================
eval "$(mise activate zsh)"
export PATH="$HOME/.local/bin:$PATH"

# Load completions once with caching
autoload -Uz compinit && compinit -C
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/albertodesaintmalo/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# =====================
# AMAZON
# =====================
alias e=emacs
alias bb=brazil-build

alias bba='brazil-build apollo-pkg'
alias bre='brazil-runtime-exec'
alias brc='brazil-recursive-cmd'
alias bws='brazil ws'
alias bwsuse='bws use -p'
alias bwscreate='bws create -n'
alias brc=brazil-recursive-cmd
alias bbr='brc brazil-build'
alias bball='brc --allPackages'
alias bbb='brc --allPackages brazil-build'
alias bbra='bbr apollo-pkg'
alias k='kiro-cli chat --trust-tools=fs_read,fs_write'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export JAVA_HOME=$(dirname $(dirname $(realpath /usr/bin/java)))
export PATH=$JAVA_HOME/bin:$PATH

# if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false

export AWS_EC2_METADATA_DISABLED=true



# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh"

# Added by AIM CLI
export PATH="$HOME/.aim/mcp-servers:$PATH"

# --- Syncthing ---
if ! pgrep -x syncthing > /dev/null; then
    nohup bash -c 'while true; do /home/linuxbrew/.linuxbrew/opt/syncthing/bin/syncthing --no-browser --no-restart; sleep 5; done' > ~/.syncthing.log 2>&1 &
fi
alias st-status="pgrep -a syncthing"
alias st-stop="pkill syncthing"
alias st-start="nohup bash -c 'while true; do /home/linuxbrew/.linuxbrew/opt/syncthing/bin/syncthing --no-browser --no-restart; sleep 5; done' > ~/.syncthing.log 2>&1 &"
alias st-log="tail -f ~/.syncthing.log"

# MeshClaw
export PATH="/workplace/adesain/superloader/MeshClaw/src/MeshClaw/bin:$PATH"

# Added by AIM CLI
export PATH="/local/home/adesain/.aim/mcp-servers:$PATH"

# bun completions
[ -s "/local/home/adesain/.bun/_bun" ] && source "/local/home/adesain/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Entire CLI shell completion
autoload -Uz compinit && compinit && source <(entire completion zsh)
