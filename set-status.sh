#!/usr/bin/env bash
# Called by tmux keybind: set-status.sh <text>
# Empty argument resets the status bar to auto mode.
if [ -z "$*" ]; then
    tmux set -g @custom_status ""
else
    tmux set -g @custom_status " $* "
fi
