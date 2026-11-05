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
export EDITOR=nvim                      # default text editor
export HOMEBREW_NO_ENV_HINTS=1          # Disable brew hints
export HOMEBREW_NO_ASK=1                # Disable brew hints
export GOPATH="$HOME/.local/share/go"   # Save path for go packages

# Hardcoded rather than `eval "$(brew shellenv)"`, which forks brew per shell
export HOMEBREW_PREFIX=/opt/homebrew

# PATH. `typeset -U` keeps it deduplicated, so no guard is needed and
# re-sourcing .zshrc is harmless. Homebrew goes ahead of the system dirs so
# its binaries win over the macOS copies.
typeset -U path
path=(
    "$HOME/.local/bin"
    "$GOPATH/bin"
    $HOMEBREW_PREFIX/{bin,sbin}
    $path
)

# Initialise the system
source "$DOTFILES/zsh/init.zsh"

