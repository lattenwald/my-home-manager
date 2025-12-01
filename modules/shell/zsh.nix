{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh-autoload-functions.nix
  ];
  # Generate shell completions during activation
  home.activation.generateZshCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.bash}/bin/bash ${../../scripts/generate-completions.sh}
  '';

  programs = {
    # lsd - modern ls replacement
    lsd = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        sorting.dir-grouping = "first";
      };
    };

    # fzf - fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      defaultCommand = "rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*'";
      fileWidgetCommand = "rg --files --no-ignore --hidden --follow -g '!{.git,node_modules}/*'";
    };

    # Zoxide - smart cd
    zoxide.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;
      defaultKeymap = "emacs";

      # Enable plugins via home-manager
      autosuggestion = {
        enable = true;
        highlight = "fg=#8888ff";
      };

      syntaxHighlighting = {
        enable = true;
      };

      # History configuration
      history = {
        path = "$HOME/.histfile";
        size = 20000;
        save = 20000;
        ignoreDups = true;
        ignoreSpace = true;
        ignoreAllDups = true;
        share = true;
        extended = false;
      };

      # Shell aliases
      shellAliases = import ./zsh-aliases.nix;

      # Session variables
      sessionVariables = {
        EDIT = "nvim";
        RSYNC_RSH = "ssh";
        XDG_DATA_HOME = "$HOME/.config";
        BUN_INSTALL = "$HOME/.bun";
      };

      # Environment variables (sourced in .zshenv)
      envExtra = ''
        # Terminal colors
        export TERM=xterm-256color
        [ -n "$TMUX" ] && export TERM=tmux-256color

        # LS_COLORS
        export LS_COLORS="$LS_COLORS:ow=1;37;42:tw=1;37;42:"

        # Cargo env
        test -f ~/.cargo/env && . ~/.cargo/env

        # PATH additions
        _paths=( \
            "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin" "$HOME/bin" \
            "$HOME/.nix-profile/bin" "/nix/var/nix/profiles/default/bin" \
            "$HOME/.asdf/shims" \
            "$HOME/.cargo/bin" \
            "$HOME/.bun/bin" \
            "$HOME/.node_modules/bin" \
            "$HOME/.cabal/bin" \
            "$HOME/.ghcup/bin" \
            "$HOME/.config/nvim/mason/bin" \
            "$HOME/.dotnet/tools" \
            "$HOME/.foundry/bin" \
            "$HOME/.lmstudio/bin" \
            "$HOME/Applications" \
            "$GOPATH" "$GOPATH/bin" \
            "/snap/bin" \
            "/usr/local/sbin" \
            "/usr/lib/smlnj/bin" \
            "/usr/local/lib/node_modules/purescript/vendor" \
            "/opt/telegram/bin" \
            "/opt/appimages" \
        )

        for _dir in "''${_paths[@]}"; do
            if [[ -d $_dir && ":$PATH:" != *":$_dir:"* ]]; then
                PATH="$_dir:$PATH"
            fi
        done

        export PATH
        unset _paths
      '';

      # Profile extra (.zprofile)
      profileExtra = ''
        export npm_config_prefix=~/.node_modules
      '';

      # Main zshrc configuration using initContent
      initContent = lib.mkMerge [
        # Commands before completion init (mkOrder 550 runs before compinit)
        (lib.mkOrder 550 ''
          # Add completion paths to fpath
          fpath=(
              /usr/share/zsh/vendor-completions   # Debian/Ubuntu
              /usr/share/zsh/site-functions       # Arch Linux
              ${pkgs.zsh-completions}/share/zsh/site-functions
              ~/.zsh/completion
              $fpath
          )
        '')

        # Main configuration
        ''
          # If not running interactively, don't do anything
          [ -z "$PS1" ] && return

          # ------------------------------------------------------------------------------
          # Desktop environment
          # ------------------------------------------------------------------------------

          if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
            export GTK_IM_MODULE="ibus"
            export XMODIFIERS="@im=ibus"
            export QT_IM_MODULE="ibus"
            export QT_QPA_PLATFORMTHEME="qt5ct"
            export TERMINAL="alacritty"
            export DMENU="rofi -dmenu"
          fi

          # ------------------------------------------------------------------------------
          # SSH Auth Sock Setup
          # ------------------------------------------------------------------------------

          # For SSH sessions: create stable symlink for tmux/screen persistence
          if [ -n "$SSH_CONNECTION" ]; then
              AUTH_SOCK_LINK="$HOME/.ssh/auth_sock.$(hostname)"
              if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
                  # Use forwarded agent
                  ln -sf "$SSH_AUTH_SOCK" "$AUTH_SOCK_LINK"
              elif [ -S "/run/user/$(id -u)/gcr/ssh" ]; then
                  # Fall back to local gcr-ssh-agent
                  ln -sf "/run/user/$(id -u)/gcr/ssh" "$AUTH_SOCK_LINK"
              elif command -v keychain >/dev/null; then
                  # Fall back to keychain (VPS/servers)
                  eval $(keychain --eval --agents ssh --quiet)
                  ln -sf "$SSH_AUTH_SOCK" "$AUTH_SOCK_LINK"
              fi
              if [ -S "$AUTH_SOCK_LINK" ]; then
                  export SSH_AUTH_SOCK="$AUTH_SOCK_LINK"
              fi
              unset AUTH_SOCK_LINK
          fi

          # ------------------------------------------------------------------------------
          # Zsh Options
          # ------------------------------------------------------------------------------

          setopt APPEND_HISTORY
          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_IGNORE_SPACE
          setopt prompt_subst

          # ------------------------------------------------------------------------------
          # Keybindings
          # ------------------------------------------------------------------------------

          typeset -A key
          key[Home]=''${terminfo[khome]}
          key[End]=''${terminfo[kend]}
          key[Insert]=''${terminfo[kich1]}
          key[Delete]=''${terminfo[kdch1]}
          key[Up]=''${terminfo[kcuu1]}
          key[Down]=''${terminfo[kcud1]}
          key[Left]=''${terminfo[kcub1]}
          key[Right]=''${terminfo[kcuf1]}
          key[PageUp]=''${terminfo[kpp]}
          key[PageDown]=''${terminfo[knp]}

          # Setup key accordingly
          [[ -n "''${key[Home]}"     ]]  && bindkey  "''${key[Home]}"     beginning-of-line
          [[ -n "''${key[End]}"      ]]  && bindkey  "''${key[End]}"      end-of-line
          [[ -n "''${key[Insert]}"   ]]  && bindkey  "''${key[Insert]}"   overwrite-mode
          [[ -n "''${key[Delete]}"   ]]  && bindkey  "''${key[Delete]}"   delete-char
          [[ -n "''${key[Up]}"       ]]  && bindkey  "''${key[Up]}"       up-line-or-history
          [[ -n "''${key[Down]}"     ]]  && bindkey  "''${key[Down]}"     down-line-or-history
          [[ -n "''${key[Left]}"     ]]  && bindkey  "''${key[Left]}"     backward-char
          [[ -n "''${key[Right]}"    ]]  && bindkey  "''${key[Right]}"    forward-char
          [[ -n "''${key[PageUp]}"   ]]  && bindkey  "''${key[PageUp]}"   history-beginning-search-backward
          [[ -n "''${key[PageDown]}" ]]  && bindkey  "''${key[PageDown]}" history-beginning-search-forward

          bindkey "\e[1;5D" backward-word #control left
          bindkey "\e[1;5C" forward-word  #control right

          # Terminal application mode
          if (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
              function zle-line-init () {
                  printf '%s' "''${terminfo[smkx]}"
              }
              function zle-line-finish () {
                  printf '%s' "''${terminfo[rmkx]}"
              }
              zle -N zle-line-init
              zle -N zle-line-finish
          fi

          # Disable Ctrl+X
          stty -ixon

          # ------------------------------------------------------------------------------
          # Completion System
          # ------------------------------------------------------------------------------

          # Completion styles
          zstyle ':completion:*' completer _expand _complete _ignored _approximate
          zstyle ':completion:*' max-errors 2 numeric
          zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
          zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,command'
          zstyle ':completion:*:processes-names' command 'ps axho command'
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path ~/.zsh/cache
          zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
          zstyle ':completion:*:cd:*' ignored-patterns '(*/)#CVS'
          zstyle ':completion:*' squeeze-slashes true
          zstyle ':completion:*:cd:*' ignore-parents parent pwd
          zstyle ':completion:*' list-colors ""
          zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
          zstyle :compinstall filename '$HOME/.zshrc'

          # Initialize bash completion compatibility
          autoload -U +X bashcompinit && bashcompinit

          # Tool-specific completions (pre-generated during activation)
          [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

          # Fix completions for: uv run <file.py>
          _uv_run_mod() {
              if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
                  if [[ ''${words[3,$((CURRENT-1))]} =~ ".*\.py" ]]; then
                      _arguments '*:filename:_files'
                  else
                      _arguments '*:filename:_files -g "*.py"'
                  fi
              else
                  _uv "$@"
              fi
          }
          compdef _uv_run_mod uv

          # ------------------------------------------------------------------------------
          # Prompt - Handled by Starship
          # ------------------------------------------------------------------------------

          # Window title in terminal
          precmd() {
              print -Pn "\e]0;%n@%m: %~\a"
          }

          # ------------------------------------------------------------------------------
          # Plugins & Tools
          # ------------------------------------------------------------------------------

          # scm_breeze - lazy-load on first git alias use
          if [ -s "$HOME/.scm_breeze/scm_breeze.sh" ]; then
            _scm_breeze_init() {
              # Unset all wrapper functions first
              unset -f _scm_breeze_init g gs gc gpl gps gd gl gst gco ga gb gf gr
              # Source SCM Breeze which will define the real aliases
              source "$HOME/.scm_breeze/scm_breeze.sh"
            }

            # Most commonly used aliases - wrapper functions
            g() { _scm_breeze_init && command git "$@"; }
            gs() { _scm_breeze_init && git_status_shortcuts "$@"; }
            gc() { _scm_breeze_init && command git commit "$@"; }
            gpl() { _scm_breeze_init && command git pull "$@"; }
            gps() { _scm_breeze_init && command git push "$@"; }
            gd() { _scm_breeze_init && command git diff "$@"; }
            gl() { _scm_breeze_init && command git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit "$@"; }
            gst() { _scm_breeze_init && command git status "$@"; }
            gco() { _scm_breeze_init && command git checkout "$@"; }
            ga() { _scm_breeze_init && git_add_shortcuts "$@"; }
            gb() { _scm_breeze_init && _scmb_git_branch_shortcuts "$@"; }
            gf() { _scm_breeze_init && command git fetch "$@"; }
            gr() { _scm_breeze_init && command git remote -v "$@"; }
          fi

          # asdf golang - lazy-load on first 'go' command
          if command -v asdf &> /dev/null && asdf current | grep -q 'golang.* true$' && [ -r ~/.asdf/plugins/golang/set-env.zsh ]; then
            go() {
              unset -f go
              source ~/.asdf/plugins/golang/set-env.zsh
              go "$@"
            }
          fi


          # API keys
          [[ -r ~/.api_keys ]] && source ~/.api_keys

          # Work machine config
          if [[ -f ~/.work-machine ]]; then
            _aws_login_with_venv() {
              local prev_venv="$VIRTUAL_ENV"
              source ~/ringcentral/aws_authenticator/venv/bin/activate
              source ~/ringcentral/aws_authenticator/bin/aws_init.sh "$@"
              if [[ -n "$prev_venv" ]]; then
                source "$prev_venv/bin/activate"
              else
                deactivate
              fi
            }

            alias aws_login="_aws_login_with_venv -l 898590214673 -u aleksandr.kiusev -r core-media-2"
            alias aws_login_hackathon="_aws_login_with_venv -l 387917828062 -u aleksandr.kiusev -r team-aidea-031-role"
          fi

          # ------------------------------------------------------------------------------
          # Finalization
          # ------------------------------------------------------------------------------

          autoload -Uz run-help
          (( ''${+aliases[run-help]} )) && unalias run-help
        ''
      ];
    };
  };
}
