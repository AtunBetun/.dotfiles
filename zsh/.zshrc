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
export PATH="$PATH:$HOME/.toolbox/bin"

# =====================
# KEYBINDINGS & ALIASES
# =====================
bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

alias vim="nvim"
alias cpwd="pwd | xclip -selection clipboard"
alias df="dotnet-fzf"
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
alias k='kiro-cli'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
