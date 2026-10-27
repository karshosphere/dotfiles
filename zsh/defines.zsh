#- Defines ---------------------------------------------------------------------
#- set up most basic common defaults -------------------------------------------

setopt notify               # report the status of background jobs immediately
setopt autocd extendedglob  # cd into directories without cd
setopt interactive_comments # allow # comments when typing interactively
setopt complete_in_word     # complete from where the cursor is, not the end
setopt always_to_end        # ...then move the cursor to the end of the word
setopt no_beep              # quiet
setopt auto_pushd pushd_ignore_dups pushd_silent # cd feeds the pushd stack

# Treat / . _ - as word separators, so Alt+Backspace eats one path segment
# instead of the whole path.
WORDCHARS=${WORDCHARS//[\/._-]}

# Updated defaults behaviour
bindkey '^[[1;9D' backward-word
bindkey '^[[1;9C' forward-word
bindkey '^[[3~'   delete-char
bindkey '^[[1;9B' backward-kill-word
bindkey '^[[3;5~' kill-word

bindkey '^[[1;3D' beginning-of-line
bindkey '^[[1;3C' end-of-line

bindkey '^[[A'    up-line-or-search
bindkey '^[[B'    down-line-or-search

bindkey -e # disable default vi support

# Alt+h/j/k/l -> arrow keys
bindkey '^[h' backward-char        # Alt+h -> left
bindkey '^[l' forward-char         # Alt+l -> right
bindkey '^[j' down-line-or-search  # Alt+j -> down
bindkey '^[k' up-line-or-search    # Alt+k -> up

# Alt+Shift+h/j/k/l -> word/line movements
bindkey '^[H' backward-word        # Alt+H -> back one word
bindkey '^[L' forward-word         # Alt+L -> forward one word
bindkey '^[J' end-of-line          # Alt+J -> end of line
bindkey '^[K' beginning-of-line    # Alt+K -> start of line

# Ctrl+G -> edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^G' edit-command-line

# Default Behaviour
alias df='df -h'
alias diff='diff --color='always''

# Common Actions
alias x=exit
alias up='cd ..'
alias weather='clear; curl wttr.in/melbourne'
alias path="echo $PATH | tr ':' '\n'"
