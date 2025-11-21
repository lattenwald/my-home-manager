''
  # Get LAN IP address
  lanip() {
      ip -4 addr show $(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}') | awk '/inet / {print $2}' | cut -d/ -f1
  }

  # Show colors
  zsh_colors() {
      for COLOR in $(seq 0 255)
      do
          for STYLE in "38;5"
          do
              TAG="\033[$${STYLE};$${COLOR}m"
              STR="$${STYLE};$${COLOR}"
              echo -ne "$${TAG}$${STR}$${NONE}  "
          done
          echo
      done
  }

  # Run command in first docker-compose service
  drun() {
      service=`cat docker-compose.yml | sed "0,/^services:/d" | head -1 | sed 's/:[[:space:]]*$//;s/^[[:space:]]*//'`
      docker-compose run $service $@
  }

  # Git: merge current branch to specified branch
  mergeto() {
      from=`git symbolic-ref --short HEAD`
      git co $* && git merge $from
  }

  # File transfer using transfer.sh
  transfer() {
      if [ $# -eq 0 ]; then
          echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
          return 1
      fi
      tmpfile=$( mktemp -t transferXXX )
      if tty -s; then
          basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
          curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
      else
          curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
      fi
      cat $tmpfile
      rm -f $tmpfile
  }

  # Search files with fzf and ripgrep
  sf() {
      if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
      printf -v search "%q" "$*"
      include="yml,js,json,php,md,styl,pug,jade,html,config,py,cpp,c,go,hs,rb,conf,fa,lst,erl,ex,exs,pl,pm,config,conf,src"
      exclude=".config,.git,node_modules,vendor,build,yarn.lock,*.sty,*.bst,*.coffee,dist"
      rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "*.{'$include'}" -g "!{'$exclude'}/*"'
      files=`eval $rg_command $search | fzf --ansi --multi --reverse | awk -F ':' '{print "+"$2":"$3" "$1}'`
      [[ -n "$files" ]] && $EDIT $files
  }

  # Search files everywhere with fzf and ripgrep
  sfe() {
      if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
      printf -v search "%q" "$*"
      rg_command='rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"'
      files=`eval $rg_command $search | fzf --ansi --multi --reverse | awk -F ':' '{print "+"$2":"$3" "$1}'`
      echo "$EDIT $files $"
      $EDIT $files
  }

  # Ripgrep with delta
  rr() {
      rg --json "$@" | delta
  }

  # View SSL certificate
  view_cert() {
      readonly host=$${1:?"The host must be specified."}
      readonly port=$${2:-"443"}
      echo certificate at $host:$port
      openssl s_client -CApath /etc/ssl/certs/ -showcerts -servername $host -connect $host:$port </dev/null | openssl x509 -text
  }

  # Arch Linux specific functions
  if [[ -f /etc/arch-release ]]; then
    # Import and sign pacman keys
    pacman-import-keys() {
        if [ $# -eq 0 ]; then
            echo "Usage: pacman-import-keys KEY1 KEY2 KEY3 ..."
            return 1
        fi

        for key in "$@"; do
            echo "==> Downloading key: $key"
            local keydata=$(curl -sS "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x$${key}")

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
    }
  fi

''
