#!/usr/bin/env bash

#- environment -----------------------------------------------------------------

set -euo pipefail

# a session renamer may wrap names in [] or <> to show state, so ghostnet answers to all three
GHOST_NAMES='ghostnet|\[ghostnet\]|<ghostnet>'

# the popup has no $TMUX, so it is handed the server's socket to keep to the same server
SOCKET="${TMUX%%,*}"
tmux() {
    command tmux ${SOCKET:+-S "$SOCKET"} "$@"
}


#- helper functions ------------------------------------------------------------

# the ghostnet session's id, whichever name it has; ids, unlike [names], are never
# taken for patterns by tmux
ghost_session() {
    tmux list-sessions -F '#{session_name}	#{session_id}' 2>/dev/null |
        grep -E "^($GHOST_NAMES)	" | head -n 1 | cut -f 2 || true
}

ghost_ensure() {
    [[ -n "$(ghost_session)" ]] || tmux new-session -d -s ghostnet
}

ghost_todo_not_focused() {
    if [[ "$(tmux display-message -p -t "$(ghost_session):" '#{window_name}')" == "todo" ]]; then
        tmux display-message "action not permitted on \"todo\" window"
        exit 0
    fi
}

current_pane() {
    tmux display-message -p '#{pane_id}'
}

ghost_active_pane() {
    tmux display-message -p -t "$(ghost_session):" '#{pane_id}'
}


#- argument parsing ------------------------------------------------------------

# these run outside a pane, from the config or in the popup, so they come before the check
case "${1:-}" in
    id)
        ghost_session
        exit 0
    ;;

    ensure)
        ghost_ensure
        exit 0
    ;;

    popup)
        tmux display-popup -c "$2" -w 60% -h 55% -E "$(printf '%q ' "$0" attach "$SOCKET")"
        exit 0
    ;;

    attach)
        SOCKET="$2"
        ghost_ensure
        # the popup is a client of its own, nested in the one it opened over
        exec env -u TMUX tmux ${SOCKET:+-S "$SOCKET"} attach-session -t "$(ghost_session)"
    ;;

    select)
        tmux select-window -t "$(ghost_session):$2"
        exit 0
    ;;
esac

[[ -n "${TMUX:-}" ]] || {
    echo "Must be run from inside tmux"
    exit 1
}

case "${1:-}" in
    back)
        ghost_ensure
        pane="$(current_pane)"
        title="$(date '+%d/%m %H:%M')"

        new_window="$(tmux break-pane \
            -s "$pane" \
            -t "$(ghost_session):" \
            -P -F '#{window_id}')"

        tmux rename-window -t "$new_window" "$title"
    ;;

    upl)
        ghost_todo_not_focused

        src_pane="$(ghost_active_pane)"
        dst_pane="$(current_pane)"

        tmux join-pane \
            -h \
            -s "$src_pane" \
            -t "$dst_pane"
    ;;

    upd)
        ghost_todo_not_focused

        src_pane="$(ghost_active_pane)"
        dst_pane="$(current_pane)"

        tmux join-pane \
            -v \
            -s "$src_pane" \
            -t "$dst_pane"
    ;;

    upn)
        ghost_todo_not_focused

        src_pane="$(ghost_active_pane)"
        dst_session="$(tmux display-message -p '#{session_id}')"

        tmux break-pane \
            -d \
            -s "$src_pane" \
            -t "${dst_session}:"
    ;;

    kill)
        ghost_todo_not_focused
        tmux kill-window -t "$(ghost_session):"
    ;;
esac

