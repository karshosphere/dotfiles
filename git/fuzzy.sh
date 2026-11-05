#!/usr/bin/env bash

WORKTREE_DIR="./.worktrees/"

#- Helper Functions --------------------------------------------------------------------------------

die() {
    echo "git: $*" >&2
    exit 1
}

# The main worktree is always listed first, even when run from inside a linked one
cd_root() {
    local root
    root=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
    [[ -n $root ]] || exit 1
    cd "$root" || die "cannot enter $root"
}

pick() {
    command -v fzf > /dev/null || die "fzf is not installed"
    fzf --height=40% --border=rounded "$@"
}

pick_branch() {
    pick --preview 'git log --oneline --color=always -n 50 {}' "$@"
}

local_branches() {
    git for-each-ref --format='%(refname:short)' refs/heads
}

remote_branches() {
    git for-each-ref --format='%(refname:lstrip=2)' refs/remotes | grep -v '/HEAD$'
}

all_branches() {
    local_branches
    remote_branches
}

is_local() {
    git show-ref --verify --quiet "refs/heads/$1"
}

# Fetches origin/feature/x into a local feature/x that tracks it, unless one exists already
make_local() {
    local remote=${1%%/*} name=${1#*/}
    is_local "$name" && return
    git fetch --quiet "$remote" "$name" && git branch --quiet --track "$name" "$1"
}

# Prints the local name for a picked branch, making a local copy of a remote one first
as_local() {
    if is_local "$1"; then
        echo "$1"
    else
        make_local "$1" && echo "${1#*/}"
    fi
}

# Current branch and each remote's default branch, local copy included
protected_branches() {
    local ref
    git branch --show-current
    git for-each-ref --format='%(symref:lstrip=2)' 'refs/remotes/*/HEAD' | while read -r ref; do
        [[ -n $ref ]] && printf '%s\n%s\n' "$ref" "${ref#*/}"
    done
}


#- Worktrees ---------------------------------------------------------------------------------------

worktree_add() {
    cd_root

    local branch name
    while IFS= read -r branch; do
        name=$(as_local "$branch") || continue
        git worktree add "$WORKTREE_DIR$(tr / - <<< "$name")" "$name"
    done < <(all_branches | pick_branch --multi --prompt='worktree add > ')
}

worktree_delete() {
    local all=0
    case $1 in
        --all) all=1 ;;
        '')    ;;
        *)     die "worktree_delete: unknown option $1" ;;
    esac

    cd_root

    local -a trees
    mapfile -t trees < <(git worktree list --porcelain | sed -n 's/^worktree //p' | tail -n +2)
    (( ${#trees[@]} )) || return 0
    (( all )) || mapfile -t trees < <(printf '%s\n' "${trees[@]}" | pick --multi --prompt='worktree remove > ' \
        --preview 'git -C {} log --oneline --color=always -n 50')

    local tree
    for tree in "${trees[@]}"; do
        git worktree remove "$tree"
    done
}


#- Branches ----------------------------------------------------------------------------------------

branch_switch() {
    local branch name
    branch=$(all_branches | pick_branch --prompt='switch > ') || return 0
    name=$(as_local "$branch") && git switch "$name"
}

branch_local() {
    local branch
    while IFS= read -r branch; do
        make_local "$branch"
    done < <(
        remote_branches | while IFS= read -r branch; do
            is_local "${branch#*/}" || echo "$branch"
        done | pick_branch --multi --prompt='make local > '
    )
}

branch_delete() {
    local all=0 delete=-d arg
    for arg in "$@"; do
        case $arg in
            --all) all=1 ;;
            -f)    delete=-D ;;
            *)     die "branch_delete: unknown option $arg" ;;
        esac
    done

    local -a branches
    mapfile -t branches < <(all_branches | grep -vxFf <(protected_branches))
    (( ${#branches[@]} )) || return 0

    if (( all )); then
        printf '  %s\n' "${branches[@]}"
        read -rp "Delete these ${#branches[@]} branches? [y/N] " arg
        [[ $arg == [yY] ]] || return 0
    else
        mapfile -t branches < <(printf '%s\n' "${branches[@]}" | pick_branch --multi --prompt='branch delete > ')
    fi

    local branch
    for branch in "${branches[@]}"; do
        if is_local "$branch"; then
            git branch "$delete" "$branch"
        else
            git push "${branch%%/*}" --delete "${branch#*/}"
        fi
    done
}


#- Rebase ------------------------------------------------------------------------------------------

rebase_branch() {
    local branch
    branch=$(all_branches | grep -vxF "$(git branch --show-current)" | pick_branch --prompt='rebase onto > ') \
        || return 0
    git rebase "$branch"
}


#- Entry Point -------------------------------------------------------------------------------------

COMMANDS=(worktree_add worktree_delete branch_switch branch_local branch_delete rebase_branch)

cmd=$1
shift

if [[ " ${COMMANDS[*]} " == *" $cmd "* ]]; then
    "$cmd" "$@"
else
    echo "git: ${cmd}: command not found" >&2
    exit 127
fi

#---------------------------------------------------------------------------------------------------
