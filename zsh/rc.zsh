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
export EDITOR=/opt/nvim-linux-x86_64/bin/nvim
export GISTS="$HOME/.local/gists"       # path for gist scripts
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && PATH="$HOME/.local/bin:$PATH"

# nrfutil autocomplete
# [[ -r "${HOME}/.nrfutil/share/nrfutil-completion/scripts/zsh/setup.zsh" ]] && \
#    . "${HOME}/.nrfutil/share/nrfutil-completion/scripts/zsh/setup.zsh"

# Initialise the system
source "$DOTFILES/zsh/init.zsh"

