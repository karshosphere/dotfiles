
#- Prompt---------------------------------------------------------------------------------------
#- custom minimal shell prompt------------------------------------------------------------------

# Each system sets its icon in zsh/icon.zsh; fall back to the generic default beside this file
source "$DOTFILES/zsh/icon.zsh" 2>/dev/null || source "${${(%):-%N}:A:h}/icon.zsh"

precmd() {
    [[ "${EUID}" -eq 0 ]] && prompeter="#" || prompeter="\$"

    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        PROMPT=$'\n'"${PROMPT_ICON}"$'  %F{12}%~%f\n%F{4}'"$prompeter"' %f'
            return
        }

    local rel="${${PWD:A}#${git_root:A}}"
    local project="${git_root:t}"

    local out
    out=$(git --no-optional-locks status --porcelain=v2 --branch \
        --untracked-files=normal --ignore-submodules 2>/dev/null)
    local -a lines=("${(@f)out}")

    local head=''
    local -i modified=0 deleted=0 renamed=0 added=0 new=0 ahead=0 behind=0
    local line xy x y ab
    for line in "${lines[@]}"; do
        case "$line" in
            '# branch.head '*)
                head="${line#\# branch.head }"
                ;;
            '# branch.ab '*)
                ab="${line#\# branch.ab }"
                ahead="${${ab%% *}#+}"
                behind="${${ab##* }#-}"
                ;;
            '? '*)
                (( new++ ))
                ;;
            '1 '*|'2 '*)
                # "<n> XY ..." — XY at chars 3-4
                xy="${line[3,4]}"
                x="${xy[1]}"; y="${xy[2]}"
                [[ $x == M ]] && (( modified++ ))
                [[ $y == M ]] && (( modified++ ))
                [[ $x == D ]] && (( deleted++ ))
                [[ $y == D ]] && (( deleted++ ))
                [[ $x == A ]] && (( added++ ))
                [[ $x == R ]] && (( renamed++ ))
                ;;
        esac
    done

    # Resolve branch label, preserving detached-HEAD appearance.
    local branch
    if [[ $head == '(detached)' ]]; then
        local ref
        ref=$(git describe --all --exact-match HEAD 2>/dev/null) \
            || ref=$(git rev-parse --short HEAD 2>/dev/null)
        branch="(detached at ${ref})"
    elif [[ -n $head ]]; then
        branch="$head"
    else
        branch="(no branch)"
    fi

    # parts array
    local -a parts=()
    (( new      )) && parts+="󱅘 $new"
    (( added    )) && parts+=" $added"
    (( modified )) && parts+=" $modified"
    (( renamed  )) && parts+="󱦹 $renamed"
    (( deleted  )) && parts+=" $deleted"
    local parts_joined="${(j: :)parts}"

    # ahead/behind, from the "# branch.ab +N -M" line (absent with no upstream)
    local -a sync=()
    (( ahead  )) && sync+="⇡$ahead"
    (( behind )) && sync+="⇣$behind"
    (( $#sync )) && parts_joined="%F{13}(${(j: :)sync})%F{2} ${parts_joined}"

	PROMPT=$'\n'"%B${PROMPT_ICON}  %F{10}${project}%b${rel} %F{7}on %F{2} %F{11}%B${branch}%b \
%F{2}${parts_joined}"$'\n%F{9}'"$prompeter"' %f'
}

