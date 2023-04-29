export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dvd"

plugins=(git)

source $ZSH/oh-my-zsh.sh

[[ -f ~/.aliases ]] && . ~/.aliases

[[ -f ~/.profile ]] && . ~/.profile

