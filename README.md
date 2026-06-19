# terminal-hud

A custom shell command for any terminal emulator that adds a persistent green status bar and syncs every terminal tab to a tmux window.

```
┌─────────────────────────────────────────────────────┐
│  $ vim src/main.py                                  │
│  ~                                                  │
│                                                     │
├─────────────────────────────────────────────────────┤
│  hostname | src | vim src/main.py                   │  ← green status bar
└─────────────────────────────────────────────────────┘
```

## Features

- **Status bar** — always-visible green bar at the bottom showing hostname, current directory, number of background jobs, and the currently running command while it executes
- **Tab age** — right side of the bar shows how long the tab has been open (e.g. `5m`, `2h`)
- **Tab sync** — each terminal tab maps 1-to-1 to a tmux window; opening a tab creates or restores a window, and `Ctrl-D` intentionally closes it
- **Crash/close recovery** — if the terminal emulator is closed, the tmux-backed tabs remain available and are reclaimed as tabs are reopened
- **Mouse scrolling** — scroll wheel enters tmux copy mode for buffer browsing; full-screen apps (vim, less) keep their own scroll handling
- **Clipboard integration** — mouse selections are automatically copied to the X11 clipboard so Ctrl-V / middle-click paste works outside tmux
- **SSH hostname tracking** — when you `ssh` into a remote server the status bar automatically switches to the remote hostname for the duration of the connection, then reverts on return
- **OSC 8 hyperlinks** — clickable links from tools like `ls --hyperlink`, `git log`, `grep --hyperlink`, etc. work end-to-end through tmux

## Requirements

- Any terminal emulator that supports a custom shell command (Terminator, GNOME Terminal, Kitty, Alacritty, Konsole, iTerm2, …)
- [tmux](https://github.com/tmux/tmux) ≥ 3.0

## Setup

1. Clone this repo somewhere permanent:

   ```sh
   git clone https://github.com/monperrus/terminal-hud ~/.config/terminal-hud
   ```

2. Configure your terminal emulator to run `terminal-shell` instead of your shell:

   | Terminal | Where to set it |
   |---|---|
   | **Terminator** | Preferences → Profiles → Command → "Run a custom command instead of my shell" |
   | **GNOME Terminal** | Preferences → Profiles → Command → "Run a custom command instead of my shell" |
   | **Kitty** | `shell` in `kitty.conf` |
   | **Alacritty** | `shell.program` in `alacritty.toml` |
   | **Konsole** | Profile → General → Command |

   Set the command to:
   ```
   /home/<you>/.config/terminal-hud/terminal-shell
   ```

3. Reopen a terminal tab.

## How it works

`terminal-shell` is what the terminal runs instead of bash. It starts (or joins) a tmux session named `terminal-hud`:

- **First tab** creates the session (tmux window 0).
- **Subsequent tabs** first reclaim any detached grouped session left behind by a closed terminal emulator. If no detached tab is available, they call `tmux new-window -P -d` to get a fresh window, then attach directly to it — so each terminal tab is an independent tmux client focused on its own window.
- **Closing a shell with `Ctrl-D`** fires an `EXIT` trap in bash that kills that tab's grouped session, keeping tmux in sync.
- **Closing the terminal emulator** only detaches the tmux clients. The pane shells, running commands, and tab sessions stay alive in tmux; reopening terminal tabs attaches to those detached sessions before creating new ones.

Inside each pane, `bash-init.sh` is sourced as the rcfile. It:

1. Sources `~/.bashrc` so your normal environment is preserved.
2. Adds a `PROMPT_COMMAND` hook that renames the tmux window to `hostname | dir | N jobs` after each command.
3. Adds a `DEBUG` trap that fires before each command runs and updates the window name to show the running command, giving live feedback while long-running programs execute.

`tmux.conf` renders `#{window_name}` in the status bar.

The tmux prefix is the default `Ctrl-b`. All standard tmux keybindings work normally.
