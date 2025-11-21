{ config, lib, ... }:

# Autoloaded Zsh functions - loaded on first use, not at startup
let
  functions = {
    lanip = ''
      # Get LAN IP address
      ip -4 addr show $(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}') | awk '/inet / {print $2}' | cut -d/ -f1
    '';

    zsh_colors = ''
      # Show terminal colors
      for COLOR in $(seq 0 255); do
        for STYLE in "38;5"; do
          TAG="\033[$STYLE;''${COLOR}m"
          STR="$STYLE;''${COLOR}"
          echo -ne "''${TAG}''${STR}\033[0m  "
        done
        echo
      done
    '';

    mergeto = ''
      # Git: merge current branch to specified branch
      local from=$(git symbolic-ref --short HEAD)
      git co "$@" && git merge "$from"
    '';

    transfer = ''
      # File transfer using transfer.sh
      if [ $# -eq 0 ]; then
        echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
      fi
      local tmpfile=$(mktemp -t transferXXX)
      if tty -s; then
        local basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"
      else
        curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile"
      fi
      cat "$tmpfile"
      rm -f "$tmpfile"
    '';

    sf = ''
      # Search files with fzf and ripgrep
      if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
      local search
      printf -v search "%q" "$*"
      local include="yml,js,json,php,md,styl,pug,jade,html,config,py,cpp,c,go,hs,rb,conf,fa,lst,erl,ex,exs,pl,pm,config,conf,src"
      local exclude=".config,.git,node_modules,vendor,build,yarn.lock,*.sty,*.bst,*.coffee,dist"
      local rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "*.{'"$include"'}" -g "!{'"$exclude"'}/*"'
      local files=$(eval "$rg_command" "$search" | fzf --ansi --multi --reverse | awk -F ':' '{print "+"$2":"$3" "$1}')
      [[ -n "$files" ]] && $EDIT $files
    '';

    sfe = ''
      # Search files everywhere with fzf and ripgrep
      if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
      local search
      printf -v search "%q" "$*"
      local rg_command='rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"'
      local files=$(eval "$rg_command" "$search" | fzf --ansi --multi --reverse | awk -F ':' '{print "+"$2":"$3" "$1}')
      [[ -n "$files" ]] && $EDIT $files
    '';

    rr = ''
      # Ripgrep with delta
      rg --json "$@" | delta
    '';

    view_cert = ''
      # View SSL certificate
      local host=''${1:?"The host must be specified."}
      local port=''${2:-"443"}
      echo "certificate at $host:$port"
      openssl s_client -CApath /etc/ssl/certs/ -showcerts -servername "$host" -connect "$host:$port" </dev/null | openssl x509 -text
    '';

    pacman-import-keys = ''
      # Import and sign pacman keys (Arch Linux only)
      if [[ ! -f /etc/arch-release ]]; then
        echo "This function is only for Arch Linux"
        return 1
      fi
      if [ $# -eq 0 ]; then
        echo "Usage: pacman-import-keys KEY1 KEY2 KEY3 ..."
        return 1
      fi

      for key in "$@"; do
        echo "==> Downloading key: $key"
        local keydata=$(curl -sS "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x''${key}")

        if [ -z "$keydata" ]; then
          echo "==> Error: Failed to download $key"
          continue
        fi

        echo "==> Importing to system keyring"
        echo "$keydata" | sudo gpg --homedir /etc/pacman.d/gnupg --import 2>&1 | grep -v "unsafe permissions"
        sudo pacman-key --lsign-key "$key" 2>&1 | grep -v "unsafe permissions"

        echo "==> Importing to user keyring"
        echo "$keydata" | gpg --import

        echo
      done
    '';
  };

  functionNames = builtins.attrNames functions;
in
{
  # Create function files in ~/.zsh/functions
  home.file = builtins.listToAttrs (map
    (name: {
      name = ".zsh/functions/${name}";
      value = {
        text = "#autoload\n${functions.${name}}";
      };
    })
    functionNames);

  # Add to fpath and autoload in zsh
  programs.zsh.initContent = lib.mkOrder 550 ''
    # Autoload custom functions
    fpath=(~/.zsh/functions $fpath)
    autoload -Uz ${builtins.concatStringsSep " " functionNames}
  '';
}
