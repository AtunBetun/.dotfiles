export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="crcandy"

plugins=(git asdf docker)

source $ZSH/oh-my-zsh.sh

fpath=(${ASDF_DIR}/completions $fpath ~/.zsh-completions)
autoload -Uz compinit && compinit

export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.bx_scripts/bin

bindkey -v
bindkey ^R history-incremental-search-backward 
bindkey ^S history-incremental-search-forward
export VI_MODE_SET_CURSOR=true

alias vim="nvim"
alias cpwd="pwd | xclip -selection clipboard"
alias df="dotnet-fzf"

autoload -U +X bashcompinit && bashcompinit

complete -C '/usr/local/bin/aws_completer' aws

export PATH=$PATH:~/.local/share/nvim/mason/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:~/.local/scripts

alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
. ~/.asdf/plugins/dotnet/set-dotnet-env.zsh
. ~/.asdf/plugins/golang/set-env.zsh
