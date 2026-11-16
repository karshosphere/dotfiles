#!/usr/bin/env bash

#-------------------------------------------------------------------------------
[[ -n "${TMUX:-}" ]] || {
    echo "Must be run from inside tmux"
    exit 1
}

set -euo pipefail

GHOSTNET="$(dirname "$0")/ghostnet.sh"
WINDOW="todo"
TODO_FILE="$HOME/.local/state/todo"

touch "$TODO_FILE"

#-------------------------------------------------------------------------------
case "${1:-}" in
    switch)
        "$GHOSTNET" ensure
        SESSION="$("$GHOSTNET" id)"

        if ! tmux list-windows -t "$SESSION" -F '#{window_name}' |
             grep -Fxq "$WINDOW"; then

            tmux new-window \
                -t "${SESSION}:0" \
                -n "$WINDOW" \
                "${EDITOR:-vi} '+set nonu nornu nocursorline' $TODO_FILE"
        fi

        tmux select-window -t "${SESSION}:${WINDOW}"
    ;;

    add)
        SESSION="$("$GHOSTNET" id)"
        user_input_tmp=$(mktemp)
        formatted_todo_tmp=$(mktemp)

        tmux display-popup \
            -w 60% \
            -h 75% \
            -E "${EDITOR:-vi} $user_input_tmp"

        if [ -s "$user_input_tmp" ]; then
            {
                echo
                date "+%d/%m/%y %H:%M"
                echo

                awk '
                {
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "")

                    if ($0 == "") {
                        if (!blank) {
                            lines[++n] = ""
                            blank = 1
                        }
                    } else {
                        lines[++n] = $0
                        blank = 0
                    }
                }

                END {
                    start = 1
                    while (start <= n && lines[start] == "")
                        start++

                    end = n
                    while (end >= start && lines[end] == "")
                        end--

                    prev = ""

                    for (i = start; i <= end; i++) {
                        if (lines[i] == "") {
                            print ""
                        } else if (i == start || prev == "") {
                            print "  - " lines[i]
                        } else {
                            print "    " lines[i]
                        }
                        prev = lines[i]
                    }
                }
                ' "$user_input_tmp"

                echo
            } > "$formatted_todo_tmp"
        fi

        rm -f "$user_input_tmp"

        tmux send-keys \
            -t "${SESSION}:${WINDOW}" \
            Escape \
            ":\$r $formatted_todo_tmp | w! | !rm $formatted_todo_tmp" \
            Enter \
            G
    ;;
esac
