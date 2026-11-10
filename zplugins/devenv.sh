#!/usr/bin/env bash

# Wrapper around docker commands to standardise devcontainer development
# utilising gh:karnull/switchboard.nvim .commands file.
# shortcuts to generalise common commands that differ consistently across projects
# devcontainer-cli isn't a dependency

COMMANDS_FILE=".commands"
ACTION=$1
shift

# cd to project root if inside git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    cd "$(git rev-parse --show-toplevel)"
fi


#-------------------------------------------------------------------------------
# default behaviour (no args)

if [ -z "$ACTION" ]; then
    lazydocker
    exit 0
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
  list            list docker containers

Default:
  <no action>     open lazydocker

Other:
  <action>        run entry from .commands file

Notes:
  - runs from git repo root if present
  - requires .commands for custom actions
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
        exit 0
        ;;

    stop|down)
        get_container_name CONTAINER
        docker stop "$CONTAINER-devcontainer"
        exit 0
        ;;

    restart|r)
        get_container_name CONTAINER
        docker stop "$CONTAINER-devcontainer"
        start_container "$CONTAINER-devcontainer"
        exit 0
        ;;

    delete|rm)
        get_container_name CONTAINER
        docker rm "$CONTAINER-devcontainer"
        exit 0
        ;;

    exec|e)
        if [ -z "$1" ]; then
            echo -e "\033[31mError: no command provided\033[0m"
            exit 1
        fi
        exec_in_container "$*"
        exit 0
        ;;

    run)
        exec_in_container "./run.sh $*"
        exit 0
        ;;

    connect|c)
        get_container_name CONTAINER
        docker exec -ti "$CONTAINER-devcontainer" bash
        exit 0
        ;;

    list|l|ls)
        docker container list
        exit 0
        ;;

    --help|-h|help|h)
        show_help
        exit 0
        ;;
esac


#-------------------------------------------------------------------------------
# require .commands file from here

if [ ! -f "$COMMANDS_FILE" ]; then
    echo -e "\033[32mCommands file not found\033[0m"
    exit 1
fi

# fallback: treat as generic action from .commands
RAW_COMMAND=$(grep "$ACTION\s*\=" "$COMMANDS_FILE" | cut -d "'" -f 2)

if [ -z "$RAW_COMMAND" ]; then
    echo -e "\033[31mUnknown action: $ACTION\033[0m"
    exit 1
fi

# substitute $@ placeholder if present, otherwise append args
if [[ "$RAW_COMMAND" == *'$@'* ]]; then
    COMMAND="${RAW_COMMAND//\$@/$*}"
else
    COMMAND="$RAW_COMMAND $*"
fi

echo -e "\033[34m> $COMMAND\033[0m"
eval "$COMMAND"
