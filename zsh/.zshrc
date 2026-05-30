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
export PATH="$HOME/.local/bin:$HOME/.bx_scripts/bin:$HOME/.local/share/nvim/mason/bin:/usr/local/go/bin:/usr/local/sbin:~/.local/scripts:/opt/nvim-linux64/bin:/home/bxuser/bin:$PATH"

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

alias vim="nvim"
alias cpwd="pwd | xclip -selection clipboard"
alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'

# =====================
# FZF
# =====================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =====================
# BASH COMPLETION SUPPORT
# =====================
autoload -U +X bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# =====================
# COMPLETIONS
# =====================
autoload -Uz compinit && compinit -C
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/albertodesaintmalo/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

export PATH=$HOME/.toolbox/bin:$PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
# Set up mise for runtime management
eval "$(mise activate zsh)"
source /Users/adesain/.brazil_completion/zsh_completion

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by AIM CLI
export PATH="/Users/adesain/.aim/mcp-servers:$PATH"
pgrep -f "autossh.*22001.*42069.*7777" > /dev/null || autossh -M 0 -f -N -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 22001:localhost:22000 -L 42069:localhost:8384 -L 7777:localhost:7777 dev-dsk-adesain-1e-701793ec.us-east-1.amazon.com
