#!/usr/bin/env bash
# Called by tmux keybind: set-status.sh <text>
# Empty argument resets the status bar to auto mode.
if [ -z "$*" ]; then
    tmux set-option -w @custom_status ""
    # Window name reverts to auto on the next PROMPT_COMMAND.
else
    tmux rename-window " $* "
    tmux set-option -w @custom_status " $* "
fi
