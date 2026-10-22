
#- CONVENIENCE -------------------------------------------------------------------------------------
#- configs specific to macos -----------------------------------------------------------------------

# List Files
alias l='eza -lag --color=always --group-directories-first --icons=always'
alias ls='eza -g --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias tree='eza -T --group-directories-first --icons=always -L'
alias treg='eza -T --group-directories-first --icons=always --git-ignore -L'

# Easier Calls
alias cat='bat -pp'
alias cp=ditto
alias htop=btop
alias ntop='sudo bandwhich'
alias systemctl="brew services"


# mise actions (local development)
eval "$(mise activate zsh)"

# Open files with set default application
of() {
    dir="${1:-.}"

    open "$dir/$(
        find "$dir/" -maxdepth 1 -type f | \
            grep -o -E "[^/]*$" | \
            sort | \
            fzf --height=40% --border=rounded
    )"
}

# Fixed Path
i() { bat -n ~/Projects/.Info/$1 }
alias vols="gt /Volumes/"

# Keyboard Remaps
fixkeyboard() {
    hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029 },{ "HIDKeyboardModifierMappingSrc":0x700000029,"HIDKeyboardModifierMappingDst":0x700000035 }] }'
}


#- System Packages ---------------------------------------------------------------------------------

alias pkga='brew install'
alias pkgr='brew uninstall --zap'
alias pkgs='brew search'
alias pkgl='brew list'
alias pkgi='brew info'
alias pkgx='brew cleanup --prune=all'

alias update='
    figlet "System Packages";
    brew upgrade;
    brew update;

    figlet "Karnull Approved";
    pushd $DOTFILES > /dev/null && {
        git pull;
        pushd generic > /dev/null && { git pull; popd > /dev/null; };
        popd > /dev/null;
    };
    pushd ~/.local/gists > /dev/null && { git pull; popd > /dev/null; };
    echo;

    figlet "Vim Plugins";
    $EDITOR --headless +"lua vim.pack.update()" +"wq" +qa;
    echo;

    figlet "System Cleanup";
    brew cleanup --prune=all;
    brew autoremove;
'

