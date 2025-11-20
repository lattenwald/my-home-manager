{ config, pkgs, lib, ... }:

{
  # Generate shell completions during activation
  home.activation.generateZshCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.bash}/bin/bash ${../../scripts/generate-completions.sh}
  '';

  programs.zsh = {
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
      size = 2000;
      save = 2000;
      ignoreDups = true;
      ignoreSpace = true;
      ignoreAllDups = true;
      share = false; # APPEND_HISTORY instead of share
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
      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      TERMINAL = "alacritty";
      DMENU = "rofi -dmenu";
    };

    # Environment variables (sourced in .zshenv)
    envExtra = ''
      # Editor setup
      which emacsclient > /dev/null && export VISUAL=emacsclient
      which vim > /dev/null && export EDITOR=vim
      which nvim > /dev/null && export EDITOR=nvim && export VISUAL=nvim

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
        # Add custom completion paths to fpath
        fpath=(
            ~/.zsh/completion
            ~/.zsh/zsh-completion
            ~/.zsh/zsh-completions/src
            $fpath
        )
      '')

      # Main configuration
      ''
        # If not running interactively, don't do anything
        [ -z "$PS1" ] && return

        # ------------------------------------------------------------------------------
        # SSH Auth Sock Setup
        # ------------------------------------------------------------------------------

        if [ -n "$SSH_TTY" ]; then
            AUTH_SOCK_LINK="$HOME/.ssh/auth_sock.$(hostname)"
            AUTH_SOCK_LINKED=$(readlink "$AUTH_SOCK_LINK")
            if ([ -z "$AUTH_SOCK_LINKED" ] || [ ! -S "$AUTH_SOCK_LINKED" ]) && [ -n "$SSH_AUTH_SOCK" ]; then
                ln -sf "$SSH_AUTH_SOCK" "$AUTH_SOCK_LINK"
            fi
            export SSH_AUTH_SOCK="$AUTH_SOCK_LINK"
            unset AUTH_SOCK_LINK
            unset AUTH_SOCK_LINKED
        else
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
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
        [[ -n "''${key[PageUp]}"   ]]  && bindkey  "''${key[PageUp]}"   beginning-of-buffer-or-history
        [[ -n "''${key[PageDown]}" ]]  && bindkey  "''${key[PageDown]}" end-of-buffer-or-history
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
        # Functions
        # ------------------------------------------------------------------------------

        ${import ./zsh-functions.nix}

        # ------------------------------------------------------------------------------
        # Plugins & Tools
        # ------------------------------------------------------------------------------

        # dnvm
        [ -s "$HOME/.dnx/dnvm/dnvm.sh" ] && . "$HOME/.dnx/dnvm/dnvm.sh"

        # scm_breeze
        [ -s "$HOME/.scm_breeze/scm_breeze.sh" ] && source "$HOME/.scm_breeze/scm_breeze.sh"

        # fzf
        [ -r "/usr/share/fzf/key-bindings.zsh" ] && \
            . "/usr/share/fzf/key-bindings.zsh" && \
            export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null' && \
            export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        [ -r ~/.fzf.zsh ] && source ~/.fzf.zsh

        # OPAM
        [ -r ~/.opam/opan-init/init.zsh ] && . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

        # conda
        [ -r /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

        # asdf
        if asdf current | grep -q 'golang.* true$' && [ -r ~/.asdf/plugins/golang/set-env.zsh ]; then
          source ~/.asdf/plugins/golang/set-env.zsh
        fi

        # zoxide
        if command -v zoxide &> /dev/null; then
            eval "$(zoxide init zsh)"
        fi

        # API keys
        [[ -r ~/.api_keys ]] && source ~/.api_keys

        # ------------------------------------------------------------------------------
        # Finalization
        # ------------------------------------------------------------------------------

        autoload -Uz run-help
        (( ''${+aliases[run-help]} )) && unalias run-help
      ''
    ];
  };

  # Starship prompt - modern, fast, async
  programs.starship = {
    enable = true;

    settings = {
      format = lib.concatStrings [
        "$time"
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$line_break"
        "$character"
      ];

      add_newline = true;

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%T";
        style = "white";
      };

      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "bold green";
        style_root = "bold red";
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style):";
        style = "bold green";
        ssh_symbol = "@";
      };

      directory = {
        format = "[$path]($style) ";
        style = "bold blue";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[$symbol$branch]($style)";
        style = "blue";
        symbol = "";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style)) ";
        style = "blue";
        ahead = ">";
        behind = "<";
        diverged = "<>";
        stashed = "<\${count}>";
        modified = "*";
        staged = "+";
        untracked = "";
        deleted = "";
        renamed = "";
      };

      character = {
        success_symbol = "[%](bold white)";
        error_symbol = "[%](bold red)";
      };
    };
  };
}
