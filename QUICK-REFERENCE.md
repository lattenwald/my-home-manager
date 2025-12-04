# Quick Reference

Shell aliases, functions, keybindings, and environment variables in this Home Manager configuration.

## Table of Contents

- [Zsh Aliases](#zsh-aliases)
- [Bash Aliases](#bash-aliases)
- [Shell Functions](#shell-functions)
- [SCM Breeze (Git Shortcuts)](#scm-breeze-git-shortcuts)
- [Git Aliases](#git-aliases)
- [Work-Only Commands](#work-only-commands)
- [Keybindings](#keybindings)
- [Environment Variables](#environment-variables)
- [Integrated Tools](#integrated-tools)

---

## Zsh Aliases

Source: `modules/shell/zsh-aliases.nix`

### File Utilities

| Alias | Command | Description |
|-------|---------|-------------|
| `df` | `duf` | Disk usage with modern UI |
| `dir` | `dir --color=auto` | Colorized dir listing |
| `vdir` | `vdir --color=auto` | Colorized verbose dir listing |
| `cpr` | `rsync -a --human-readable --progress` | Copy with progress |
| `ff` | `fd -IH` | Find files (include hidden/ignored) |

### Text Processing

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `grep --color=auto` | Colorized grep |
| `fgrep` | `grep -F --color=auto` | Fixed-string grep |
| `egrep` | `grep -E --color=auto` | Extended regex grep |

### System Utilities

| Alias | Command | Description |
|-------|---------|-------------|
| `watch` | `watch --color` | Watch with color support |
| `pacman` | `pacman --color auto` | Colorized pacman |
| `pactree` | `pactree --color` | Colorized dependency tree |
| `ports` | `ss -lptun` | Show listening ports |
| `colors` | *(script)* | Display 256 terminal colors |
| `hwinfo` | *(script)* | Show hardware info via dmidecode |

### Network

| Alias | Command | Description |
|-------|---------|-------------|
| `wanip` | `dig +short myip.opendns.com @resolver1.opendns.com` | Get public IP |
| `wanip4` | *(dig variant)* | Get public IPv4 |
| `wanip6` | *(dig variant)* | Get public IPv6 |

### SSH/SCP

| Alias | Command | Description |
|-------|---------|-------------|
| `ssh_close` | `ssh -O exit` | Close SSH control master |
| `scp` | `/usr/bin/scp -o ControlMaster=no` | SCP without control master |

### Editors

| Alias | Command | Description |
|-------|---------|-------------|
| `vim` | `nvim` | Use neovim as vim |
| `v` | `nvim` | Quick neovim shortcut |

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `gg` | `lazygit` | Terminal UI for git |

### Docker

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker compose` | Docker compose shortcut |

### Misc

| Alias | Command | Description |
|-------|---------|-------------|
| `help` | `run-help` | Zsh help system |

---

## Bash Aliases

Source: `modules/bash.nix`

Minimal set since zsh is the primary shell.

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `grep --color=auto` | Colorized grep |
| `fgrep` | `fgrep --color=auto` | Fixed-string grep |
| `egrep` | `egrep --color=auto` | Extended regex grep |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |

*Note: `ll`, `la`, `l` are provided by lsd via `enableBashIntegration`*

---

## Shell Functions

Source: `modules/shell/zsh-autoload-functions.nix`

Autoloaded on first use (not at startup).

### Network

| Function | Description |
|----------|-------------|
| `lanip` | Get LAN IP address of default interface |
| `view_cert HOST [PORT]` | View SSL certificate (default port 443) |
| `transfer FILE` | Upload file to transfer.sh |

### Search & Edit

| Function | Description |
|----------|-------------|
| `sf QUERY` | Search files with fzf+ripgrep, open in editor |
| `sfe QUERY` | Search everywhere (no ignores) with fzf+ripgrep |
| `rr QUERY` | Ripgrep with delta (colorized output) |

### Git

| Function | Description |
|----------|-------------|
| `mergeto BRANCH` | Merge current branch to specified branch |

### System

| Function | Description |
|----------|-------------|
| `zsh_colors` | Display all 256 terminal colors |
| `pacman-import-keys KEY...` | Import and sign pacman keys (Arch only) |

---

## SCM Breeze (Git Shortcuts)

Source: `~/.scm_breeze/` (lazy-loaded on first use)

Numeric shortcuts for git files (e.g., `ga 1 2 3`).

| Shortcut | Command | Description |
|----------|---------|-------------|
| `g` | `git` | Git with SCM Breeze |
| `gs` | `git status` | Status with file numbers |
| `ga` | `git add` | Add by number (`ga 1 2`) |
| `gc` | `git commit` | Commit |
| `gd` | `git diff` | Diff |
| `gl` | `git log` | Pretty log graph |
| `gco` | `git checkout` | Checkout |
| `gb` | `git branch` | Branch with shortcuts |
| `gf` | `git fetch` | Fetch |
| `gr` | `git remote -v` | Show remotes |
| `gpl` | `git pull` | Pull |
| `gps` | `git push` | Push |
| `gst` | `git status` | Status |

---

## Git Aliases

Source: `modules/git.nix` (used as `git <alias>`)

| Alias | Command | Description |
|-------|---------|-------------|
| `co` | `checkout` | |
| `ci` | `commit` | |
| `st` | `status` | |
| `br` | `branch` | |
| `ls` | `ls-tree -r --name-only` | List files in tree |
| `undo` | `reset --hard` | Discard all changes |
| `undo-commit` | `reset --soft HEAD^` | Undo last commit (keep changes) |
| `unstage` | `reset` | Unstage files |
| `wdiff` | `diff --color-words` | Word-level diff |
| `ndiff` | `diff --name-only` | Show only changed filenames |
| `tags` | `tag -l` | List tags |
| `addremove` | *(script)* | Stage all changes (add + remove) |
| `addre` | *(script)* | Same as addremove |
| `l` | *(log format)* | Pretty log graph with colors |
| `rpull` | `submodule update --recursive --remote` | Update submodules |
| `rclone` | `clone --recursive` | Clone with submodules |
| `pullall` | *(script)* | Pull + update submodules |

---

## Work-Only Commands

Source: `modules/work.nix` (only when `~/.work-machine` exists)

### SSH with Password

| Command | Description |
|---------|-------------|
| `sshw user@host` | SSH with password from GNOME Keyring |
| `sshw user@host cmd` | Run command via password-based SSH |

**Setup:**
```bash
secret-tool store --label='RC autodeploy' user autodeploy service rc-coremedia2
```

**Tab completion:** Users from `~/.config/sshw/users`, hosts from `~/.config/sshw/hosts`

### AWS

| Command | Description |
|---------|-------------|
| `aws_login` | Login to core-media-2 AWS account |
| `aws_login_hackathon` | Login to hackathon AWS account |

---

## Keybindings

Source: `modules/shell/zsh.nix`

### Navigation

| Key | Action |
|-----|--------|
| `Home` | Beginning of line |
| `End` | End of line |
| `Ctrl+Left` | Backward word |
| `Ctrl+Right` | Forward word |
| `Delete` | Delete character |
| `Insert` | Toggle overwrite mode |

### History

| Key | Action |
|-----|--------|
| `Up` | Previous history |
| `Down` | Next history |
| `PageUp` | History search backward |
| `PageDown` | History search forward |

### FZF (when active)

| Key | Action |
|-----|--------|
| `Ctrl+T` | File search |
| `Ctrl+R` | History search |
| `Alt+C` | Directory search |

---

## Environment Variables

Source: `modules/shell/zsh.nix`

### Session Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `EDITOR` | `nvim` | Default editor |
| `VISUAL` | `nvim` | Visual editor |
| `EDIT` | `nvim` | Used by custom functions |
| `RSYNC_RSH` | `ssh` | Rsync over SSH |
| `TERM` | `xterm-256color` | Terminal type |

### Desktop Variables (GUI only)

Set when `$DISPLAY` or `$WAYLAND_DISPLAY` exists:

| Variable | Value |
|----------|-------|
| `GTK_IM_MODULE` | `ibus` |
| `QT_IM_MODULE` | `ibus` |
| `XMODIFIERS` | `@im=ibus` |
| `QT_QPA_PLATFORMTHEME` | `qt5ct` |
| `TERMINAL` | `alacritty` |
| `DMENU` | `rofi -dmenu` |

### PATH Additions

Directories added to PATH (if they exist):
- `~/.local/bin`, `~/bin`, `~/.bin`
- `~/.nix-profile/bin`
- `~/.cargo/bin`
- `~/.bun/bin`
- `~/.asdf/shims`
- `~/.node_modules/bin`
- `~/.cabal/bin`, `~/.ghcup/bin`
- `$GOPATH/bin`
- And more (see `zsh.nix` for full list)

---

## Integrated Tools

Managed by Home Manager with shell integration enabled.

| Tool | Description | Integration |
|------|-------------|-------------|
| `lsd` | Modern ls replacement | `ll`, `la`, `l` aliases |
| `fzf` | Fuzzy finder | `Ctrl+T`, `Ctrl+R`, `Alt+C` |
| `zoxide` | Smart cd | `z` command |
| `starship` | Prompt | Cross-shell prompt |
| `delta` | Git diff viewer | Git pager |
| `zsh-autosuggestions` | Command suggestions | Gray text hints |
| `zsh-syntax-highlighting` | Syntax colors | Command highlighting |
