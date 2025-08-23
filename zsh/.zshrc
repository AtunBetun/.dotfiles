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
export ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME/.asdf}"
export PATH="$ASDF_DATA_DIR/shims:$HOME/.local/bin:$HOME/.bx_scripts/bin:$HOME/.local/share/nvim/mason/bin:/usr/local/go/bin:/usr/local/sbin:~/.local/scripts:/opt/nvim-linux64/bin:/home/bxuser/bin:$PATH"

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

# =====================
# BASH COMPLETION SUPPORT
# =====================
autoload -U +X bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# =====================
# ASDF SETUP
# =====================
# Load ASDF plugin environments (dotnet & go)
[ -f "$ASDF_DATA_DIR/plugins/dotnet/set-dotnet-env.zsh" ] && . "$ASDF_DATA_DIR/plugins/dotnet/set-dotnet-env.zsh"
[ -f "$ASDF_DATA_DIR/plugins/golang/set-env.zsh" ] && . "$ASDF_DATA_DIR/plugins/golang/set-env.zsh"

# ASDF completions (only generate once)
if [ ! -f "$ASDF_DATA_DIR/completions/_asdf" ]; then
    mkdir -p "$ASDF_DATA_DIR/completions"
    asdf completion zsh > "$ASDF_DATA_DIR/completions/_asdf"
fi
fpath=("$ASDF_DATA_DIR/completions" $fpath)

# Load completions once with caching
autoload -Uz compinit && compinit -C
