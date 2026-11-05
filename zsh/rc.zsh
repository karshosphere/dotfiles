#
#-------------------------------------------------------------------------------
#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ | | | | | | (__
# (_/___|___|_| |_|_|  \___|
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# System specific configs
export DOTFILES="${${(%):-%N}:A:h:h}"   # path for system configs
export EDITOR=nvim
export GISTS="$HOME/.local/gists"       # path for gist scripts

[[ $PATH != *"$HOME/.local/bin" ]] && PATH="${PATH%:}:"$HOME/.local/bin""

# Initialise the system
source "$DOTFILES/zsh/init.zsh"

