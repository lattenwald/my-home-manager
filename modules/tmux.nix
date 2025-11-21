{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    # Screen-like prefix (^A instead of ^B)
    prefix = "C-a";
    keyMode = "vi";
    terminal = "tmux-256color";
    newSession = true;
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 10000;

    # Explicit for vim; also set by sensible
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-processes 'htop "make run" hbr-xdp exabgp- k9s'
          set -g @resurrect-save 'M-s'
          set -g @resurrect-restore 'M-r'
        '';
      }
    ];

    extraConfig = ''
      # Screen-like keybindings (additions to defaults)
      bind a send-prefix              # nested tmux/screen
      bind ^C new-window -c "#{pane_current_path}"  # c exists, ^C uses current path
      bind * list-clients
      bind A command-prompt "rename-window %%"
      bind ^A last-window
      bind ^W list-windows            # w exists, add ^W
      bind '\' confirm-before "kill-server"
      bind K confirm-before "kill-window"
      bind k confirm-before "kill-pane"
      bind S split-window -c "~"
      bind ^s split-window -c "#{pane_current_path}"
      bind Tab select-pane -t:.+
      bind BTab select-pane -t:.-
      bind '"' choose-window

      # Reload config (XDG path, not ~/.tmux.conf)
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"
      bind l next-layout

      # Status bar
      set -g status-bg brightblack
      set -g status-fg white
      set -g status-left ' '
      set -g status-right '#[fg=brightgreen]#H#[fg=white] | #(date +%H:%M) '
      set-window-option -g window-status-format '#I #W#{?window_zoomed_flag,(z),} '
      set-window-option -g window-status-current-format '#[fg=red][#[fg=white,bold]#I #W#{?window_zoomed_flag, (zoom),}#[fg=red]]#[fg=white] '

      setw -g monitor-activity on
      set -g visual-activity off

      # Disable Alt-n/p (conflicts with vim Esc sequences)
      unbind -n M-n
      unbind -n M-p

      # Docker env vars (SSH vars already in tmux defaults)
      set-option -ga update-environment " DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_TLS_VERIFY DOCKER_CERT_PATH"

      # Pane movement between windows
      bind-key j command-prompt -p "send pane to:"  "join-pane -t '%%'"
      bind-key J command-prompt -p "send pane (split horizontally) to:"  "join-pane -h -t '%%'"
      bind / display-panes

      # Vi copy mode (non-default bindings)
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
      bind-key -T copy-mode-vi 'y' send-keys -X copy-selection
      bind-key -T copy-mode-vi 'Y' send-keys -X copy-line
      bind-key -T copy-mode-vi 'H' send-keys -X start-of-line
      bind-key -T copy-mode-vi 'L' send-keys -X end-of-line
    '';
  };
}
