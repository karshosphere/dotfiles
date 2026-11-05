#- CONVENIENCE -------------------------------------------------------------------------------------
#- configs specific to macos -----------------------------------------------------------------------

# List Files
alias l='eza -lag --color=always --group-directories-first --icons=always'
alias ls='eza -g --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias tree='eza -T --group-directories-first --icons=always -L'
alias treg='eza -T --group-directories-first --icons=always --git-ignore -L'

# Easier Calls
alias cn='bat -n'        # cat with line numbers -- plain `c` is clear -x
alias cat='bat -pp'
alias htop=btop
alias ntop='sudo bandwhich'

#- System Packages ---------------------------------------------------------------------------------

alias pkga='sudo apt install --no-install-recommends'
alias pkgr='sudo apt purge --autoremove'
alias pkgs='apt search'
alias pkgl='apt list --installed'
alias pkgi='apt show'
alias pkgx='sudo apt autoremove; sudo apt autoclean'

alias update='
    sudo figlet "System Packages";
    sudo apt upgrade;
    sudo apt update;

    figlet "Karnull Approved";
    pushd ~/.config/dotfiles > /dev/null && {
        git pull;
        pushd generic > /dev/null && {
            git switch main;
            git pull;
            git switch "chore/cloud-updates";
            git rebase main;
            popd > /dev/null;
        };
        popd > /dev/null;
    };
    pushd $GISTS > /dev/null && { git pull; popd > /dev/null; };
    echo;

    figlet "Vim Plugins";
    $EDITOR --headless +"lua vim.pack.update()" +"wq" +qa;
    echo;

    figlet "System Cleanup";
    sudo apt autoremove;
    sudo apt autoclean
'
