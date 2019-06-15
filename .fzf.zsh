# Setup fzf
# ---------
# if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
#   export PATH="$PATH:/usr/local/opt/fzf/bin"
# fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

# export FZF_DEFAULT_COMMAND='ag --nocolor --hidden --ignore .git --ignore vendor -g ""'
# export FZF_DEFAULT_COMMAND="rg -uu -g '!vendor' -g '!.git' --files"
# [ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'

if [ ! -z "$(command -v fd)" ]; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# https://github.com/junegunn/blsd
# command -v blsd > /dev/null && export FZF_ALT_C_COMMAND='blsd $dir'
# brew install tree
command -v tree > /dev/null && export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -n 200'"
# brew install bat
command -v bat > /dev/null && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} | head -n 200'"

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command into clipboard' --border"

