
#- CONVENIENCE -------------------------------------------------------------------------------------
#- configs specific to wsl -------------------------------------------------------------------------

# List Files
alias l='eza -lag --color=always --group-directories-first --icons=always'
alias le="explorer.exe ."
alias ls='eza -g --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias tree='eza --long -T --group-directories-first --icons=always -L'
alias treg='eza --long -T --group-directories-first --icons=always --git-ignore --all -L '
trec() {
    eza -T --group-directories-first -F -L $1 | clip.exe
}

# Easier Calls
winc() { cp -r $@ /mnt/d/LinShare/. }
winm() { mv $@ /mnt/d/LinShare/. }
winf() { cat $@ | clip.exe }
alias cat='bat -p -n'
alias cp='cp -r'
alias co=copilot
alias htop=btop
alias r=ranger
alias pse=powershell.exe
alias usbipd='powershell.exe usbipd'
 

#- Local Development -------------------------------------------------------------------------------

# NRF utils
nrfconnect() { /opt/nrf-destop/nrfconnect --no-sandbox >/dev/null 2>&1 & disown %+; }
alias killnrfconnect='pkill -9 -f "/opt/nrf-desktop/nrfconnect" >/dev/null 2>&1 || true'


#- System Packages ---------------------------------------------------------------------------------

alias pkga='sudo apt install --no-install-recommends'
alias pkgr='sudo apt purge'
alias pkgx='sudo apt autoclean; sudo apt autoremove'
alias pkgl='dpkg -l | fzf -e'
pkgs() { apt-cache search $1 | fzf -e }

alias update='
    sudo echo
    figlet "System Packages" | lolcat -t -S 10
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt --fix-broken install -y > /dev/null 2>&1
    echo

    figlet "Repos Pull" | lolcat -t -S 10
    pushd $DOTFILES > /dev/null && {
        git pull
        pushd generic > /dev/null && {
            git switch main
            git pull
            git switch "chore/work-system"
            git rebase main
            popd > /dev/null
        }
        popd > /dev/null
    }
    pushd $GISTS > /dev/null && { git pull; popd > /dev/null }
    echo

    figlet "Vim Plugins" | lolcat -t -S 10
    vim --headless +"lua vim.pack.update()" +"wq" +qa | lolcat
    echo -e "\n"

    figlet "UV tools" | lolcat -t -S 10
    uv tool upgrade --all
    echo

    figlet "System Cleanup" | lolcat -t -S 10
    sudo apt autoremove --purge
    sudo apt clean
    sudo rm -rf /var/cache/apt/archives/partial/*(N) 2 > /dev/null
'

