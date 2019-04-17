# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

### Disable CTRL-S and CTRL-Q
[[ $- =~ i ]] && stty -ixoff -ixon

# use the Dvorak keyboard for the basis for examining spelling mistakes
setopt DVORAK

# history settings
setopt EXTENDED_HISTORY    # writes the history file in the *:start:elapsed;command* format
setopt INC_APPEND_HISTORY  # writes to the history file immediately, not when the shell exits
setopt HIST_IGNORE_DUPS    # does not record an event that was just recorded again.
setopt HIST_SAVE_NO_DUPS   # does not write a duplicate event to the history file
setopt HIST_IGNORE_SPACE   # does not record an event starting with a space
SAVEHIST=8192
HISTSIZE=8192              # stores the maximum number of events to save in the internal history

# export BACKGROUND="light"

# https://github.com/BurntSushi/ripgrep
[ -f "$HOME/.rgrc" ] && export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

# Bindings
# http://zsh.sourceforge.net/Intro/intro_11.html#SEC11
# bindkey '^A' beginning-of-line
# bindkey '^E' end-of-line
# bindkey '^K' kill-line
# bindkey '^[H' run-help
# ctrl + enter = accept-and-hold
bindkey '^[[13;5u' accept-and-hold
# in vi mode use j/k for history-substring search
# bindkey '^P' history-substring-search-up
# bindkey '^N' history-substring-search-down
bindkey '^[OA' up-line-or-history
bindkey '^[OB' down-line-or-history
# shift + tab
# bindkey '^[[Z' autosuggest-accept

# following just for reference
# ^Q push-line-or-edit

# history-incremental is from editor module
# in vi mode / = history-incremental-search-forward
# in vi mode ? = history-incremental-search-backward

# To view all vicmd bindings: bindkey -M vicmd
# bindkey -M vicmd '^U' vi-kill-line

# fzf bindings
# to view all: bindkey-all | rg -i fzf
# http://junegunn.kr/2016/07/fzf-git/
# first unbind '^G', which is bound to list-expand by default
bindkey '^G' undefined-key
# for tags
bindkey '^Gt' fzf-gt-widget
# for commit hashes
bindkey '^Gh' fzf-gh-widget
# for files
bindkey '^Gf' fzf-gf-widget
# for branches
bindkey '^Gb' fzf-gb-widget
# for remotes
bindkey '^Gr' fzf-gr-widget
# for stashes
bindkey '^Gs' fzf-gs-widget

# https://github.com/kurkale6ka/zsh/blob/master/.zshrc
### ^x0 IPs
bindkey -s '^x0' '127.0.0.1'
bindkey -s '^x1' '10.0.0.'
bindkey -s '^x7' '172.16.0.'
bindkey -s '^x9' '192.168.0.'

### ^x_ /dev/null
bindkey -s '^x_' '/dev/null'

# [ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.zsh

# https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Source functions
[ -f ~/.myfuncs.zsh ] && source ~/.myfuncs.zsh

# Source aliases
[ -f ~/.aliases ] && source ~/.aliases
