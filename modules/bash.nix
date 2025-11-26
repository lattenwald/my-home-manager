_:
{
  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" "erasedups" ];
    historySize = 10000;
    historyFileSize = 20000;

    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
    ];

    shellAliases = {
      # Note: ll, la, l are provided by lsd via enableBashIntegration
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initExtra = ''
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Prompt handled by Starship (% for zsh, $ for bash)
      # FZF handled by programs.fzf.enableBashIntegration

      # Local overrides (for secrets, machine-specific)
      if [ -f ~/.bashrc.local ]; then
        source ~/.bashrc.local
      fi
    '';
  };
}
