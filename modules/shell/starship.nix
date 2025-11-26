{ lib, ... }:
{
  # Starship prompt - modern, fast, cross-shell
  programs.starship = {
    enable = true;

    settings = {
      format = lib.concatStrings [
        "$time"
        "$username"
        "$hostname"
        "\${custom.ssh_prompt}"
        "$directory"
        "$git_branch"
        "$git_status"
        "$line_break"
        "\${custom.char_zsh}"
        "\${custom.char_other}"
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
        detect_env_vars = [ "!SSH_CONNECTION" ]; # Hide when SSH
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style):";
        style = "bold green";
        detect_env_vars = [ "!SSH_CONNECTION" ]; # Hide when SSH
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

      custom = {
        # Yellow user@host when connected via SSH
        ssh_prompt = {
          when = ''test -n "$SSH_CONNECTION"'';
          format = "[$output]($style):";
          command = ''echo "$USER@$(hostname)"'';
          style = "bold yellow";
        };

        # Shell-specific prompt characters: % for zsh, $ for others
        char_zsh = {
          when = ''test "$STARSHIP_SHELL" = "zsh"'';
          command = "echo '%'";
          format = "[$output](bold white) ";
        };

        char_other = {
          when = ''test "$STARSHIP_SHELL" != "zsh"'';
          command = "echo '$'";
          format = "[$output](bold white) ";
        };
      };
    };
  };
}
