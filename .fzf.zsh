# Setup fzf
# ---------
if [[ ! "$PATH" == */home/vizman/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/vizman/.fzf/bin"
fi

source <(fzf --zsh)
