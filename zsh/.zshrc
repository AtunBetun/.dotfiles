export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="crcandy"

plugins=(git docker)

source $ZSH/oh-my-zsh.sh

# fpath=(${ASDF_DIR}/completions $fpath ~/.zsh-completions)
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
alias docker="podman"

autoload -U +X bashcompinit && bashcompinit

complete -C '/usr/local/bin/aws_completer' aws

export PATH=$PATH:~/.local/share/nvim/mason/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:~/.local/scripts
export PATH="$PATH:/opt/nvim-linux64/bin"

alias killbg='kill -KILL ${${(v)jobstates##*:*:}%=*}'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# . ~/.asdf/plugins/dotnet/set-dotnet-env.zsh
# . ~/.asdf/plugins/golang/set-env.zsh
#
# export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
# asdf completion zsh > "${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"
#
# fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

if [ -e /home/bxuser/.nix-profile/etc/profile.d/nix.sh ]; then . /home/bxuser/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/ZscalerRootCertificate-2048-SHA256.crt

# added by Snowflake SnowSQL installer
export PATH=/home/bxuser/bin:$PATH
# bun completions
[ -s "/home/atunbetun/.bun/_bun" ] && source "/home/atunbetun/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$PATH:/home/atunbetun/.dotnet/tools"
