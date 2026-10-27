
#- NAVIGATE --------------------------------------------------------------------
#- file processing and navigation ----------------------------------------------

# Faaster Navigate -------------------------------------------------------------

cdir() {
    mkdir -p -- "$1" && cd -- "$1"
}

count() {
    ls -- "${1:-.}" | wc -l | tr -d ' '
}

# Function to run fzf with dynamic preview position
gt() {
    local dynamic_fzf() {
        local term_width=$(tput cols)

        if [ "$term_width" -lt 150 ]; then
            fzf --height=85% --border=rounded \
                --preview-window=down:70%:wrap \
                --preview="eza -T --color=always --icons=always -L 1 "$dir/{}""
        else
            fzf --height=40% --border=rounded \
                --preview-window=right:50%:wrap \
                --preview="eza -T --color=always --icons=always -L 1 "$dir/{}""
        fi
    }

    dir="${1:-.}"
    cd "$dir/$(
        find -L "$dir" -maxdepth 1 -mindepth 1 \( -type d -o -type l \) -not -path '*/.*' |
            grep -o -E "[^/]*$" |
            sort |
            dynamic_fzf
        )"
}

alias p="gt ~/Projects"
alias b="gt .."
alias docs="gt ~/Documents"
alias down="gt ~/Downloads"
alias conf="cd $DOTFILES"
