#!/usr/bin/env bash

# Wrapper around docker commands to standardise devcontainer development
# devcontainer-cli isn't a dependency

ACTION=$1
shift

# cd to project root if inside git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    cd "$(git rev-parse --show-toplevel)"
fi


#-------------------------------------------------------------------------------
# default behaviour (no args)

if [ -z "$ACTION" ]; then
    exec lazydocker
fi

show_help() {
cat <<'EOF'
Usage: script [action] [args...]

Actions:
  up              start devcontainer, or create one from the project image
  down            stop devcontainer
  restart         restart devcontainer
  delete          delete devcontainer
  exec <CMD>      run CMD in devcontainer
  run [ARGS]      run ./run.sh ARGS in devcontainer
  connect         open shell in devcontainer
  list            list running containers, with short image hashes

Default:
  <no action>     open lazydocker

Notes:
  - runs from git repo root if present
EOF
}

#-------------------------------------------------------------------------------
# helper function

get_container_name() {
    local -n _out=$1
    local result

    if [ -f ".devcontainer/compose.yaml" ]; then
        result=$(grep '^[[:space:]]*name:' .devcontainer/compose.yaml | cut -d ' ' -f 2)
        if [ -n "$result" ]; then
            _out="$result"
            return 0
        fi
    fi

    _out="${PWD##*/}"
}

get_project_name() {
    local main_worktree
    main_worktree=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
    basename "${main_worktree:-$PWD}"
}

# VS Code tags its images vsc-<folder>-<hash>[-features]-uid, folder lowercased
find_project_image() {
    local project
    project=$(get_project_name | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9._-')
    project=${project//./\\.}

    docker image ls --format '{{.Repository}}' \
        | grep -E -m 1 "^vsc-${project}-[0-9a-f]{16,}(-features)?-uid$"
}

create_container() {
    local mounts=(-v "$PWD:/workspaces/${PWD##*/}")
    local git_dir
    git_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)

    # a worktree's .git file points at the main repo by absolute path
    if [ -n "$git_dir" ] && [ "$git_dir" != "$PWD/.git" ]; then
        mounts+=(-v "$git_dir:$git_dir")
    fi

    docker run -d --init --name "$1" \
        "${mounts[@]}" \
        -w "/workspaces/${PWD##*/}" \
        --label "devcontainer.local_folder=$PWD" \
        --label "devcontainer.config_file=$PWD/.devcontainer/devcontainer.json" \
        --entrypoint sleep "$2" infinity
}

start_container() {
    if docker container inspect "$1" >/dev/null 2>&1; then
        docker start "$1"
        return
    fi

    echo -e "\033[33m! No existing container with the name $1\033[0m"

    local image
    if [ ! -f ".devcontainer/compose.yaml" ] && image=$(find_project_image); then
        echo -e "\033[34m! Creating it from the image $image\033[0m"
        create_container "$1" "$image"
    else
        echo -e "\033[34m! Starting visual studio code to build\033[0m"
        code .
    fi
}

# shortens image hashes to abc...xyz, and aligns in awk so column isn't needed
list_containers() {
    {
        printf 'NAMES\tIMAGE\tSTATUS\tPORTS\n'
        docker container list --format '{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
    } | sed -E 's/^([^\t]*\t[^\t]*-[0-9a-f]{3})[0-9a-f]{10,}([0-9a-f]{3})/\1...\2/' \
      | awk -F'\t' '
        {
            for (i = 1; i <= NF; i++) {
                cell[NR, i] = $i
                if (length($i) > width[i]) width[i] = length($i)
            }
            if (NF > cols) cols = NF
        }
        END {
            for (r = 1; r <= NR; r++) {
                line = ""
                for (i = 1; i < cols; i++) line = line sprintf("%-" width[i] + 3 "s", cell[r, i])
                line = line cell[r, cols]
                sub(/ +$/, "", line)
                print line
            }
        }'
}

exec_in_container() {
    get_container_name CONTAINER
    docker exec -w "/workspaces/`basename "$PWD"/`" "$CONTAINER-devcontainer" sh -c "$1"
}


#-------------------------------------------------------------------------------
# special commands

case "$ACTION" in
    start|up)
        get_container_name CONTAINER
        start_container "$CONTAINER-devcontainer"
        ;;

    stop|down)
        get_container_name CONTAINER
        docker stop "$CONTAINER-devcontainer"
        ;;

    restart|r)
        get_container_name CONTAINER
        docker stop "$CONTAINER-devcontainer" &&
            start_container "$CONTAINER-devcontainer"
        ;;

    delete|rm)
        get_container_name CONTAINER
        docker rm "$CONTAINER-devcontainer"
        ;;

    exec|e)
        if [ -z "$1" ]; then
            echo -e "\033[31mError: no command provided\033[0m"
            exit 1
        fi
        exec_in_container "$*"
        ;;

    run)
        exec_in_container "./run.sh $*"
        ;;

    connect|c)
        get_container_name CONTAINER
        docker exec -ti "$CONTAINER-devcontainer" bash
        ;;

    list|l|ls)
        list_containers
        ;;

    --help|-h|help|h)
        show_help
        ;;

    *)
        echo -e "\033[31mUnknown action: $ACTION\033[0m"
        exit 1
        ;;
esac
