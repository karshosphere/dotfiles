#!/usr/bin/env bash

# ghostnet has its own popup, by any name a session renamer gives it
session=$(
    tmux ls |
    grep -vE '^(ghostnet|\[ghostnet\]|<ghostnet>):' |
    fzf --tmux 85,15 -i --layout=reverse --cycle |
    cut -f 1 -d ":"
);

# = matches the name exactly, so a [bracketed] name isn't taken for a pattern
if [ -n "$session" ]; then
     tmux switch-client -t "=$session";
fi

