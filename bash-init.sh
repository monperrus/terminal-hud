# Sourced as the --rcfile for bash running inside the tmux pane.
# Sources the user's normal bashrc first, then adds the status-bar hook.

[ -f ~/.bashrc ] && source ~/.bashrc

_terminator_update_status() {
    [ -z "$TMUX" ] && return
    local jobs_count
    jobs_count=$(jobs 2>/dev/null | wc -l)
    local label
    local dir="${PWD##*/}"
    label=" $(hostname -s) | ${dir:-/} | ${jobs_count} job$( [ "$jobs_count" -ne 1 ] && echo s ) "
    tmux set-option -g @auto_status "$label" 2>/dev/null
}

# Prepend to PROMPT_COMMAND so it runs before any user-defined hooks.
PROMPT_COMMAND="_terminator_update_status${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Kill the tmux window when this shell exits (i.e. when the Terminator tab closes).
trap 'tmux kill-window 2>/dev/null' EXIT
