{ config, lib, pkgs, ... }:

let
  homeDirectory = builtins.getEnv "HOME";
  isWorkMachine = builtins.pathExists "${homeDirectory}/.work-machine";
  configDir = "${homeDirectory}/.config/sshw";
in
{
  config = lib.mkIf isWorkMachine {
    home.packages = [ pkgs.sshpass ];

    # Create completion files only if they don't exist (one-time seed)
    home.activation.sshpConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${configDir}"
      if [[ ! -f "${configDir}/users" ]]; then
        echo "autodeploy" > "${configDir}/users"
      fi
      if [[ ! -f "${configDir}/hosts" ]]; then
        echo "rnd01-t02-lgs15" > "${configDir}/hosts"
      fi
    '';

    programs.zsh.initContent = ''
      # sshw: SSH with password from GNOME Keyring (rc-coremedia2 service)
      sshw() {
        local target="$1"
        shift
        local user="''${target%@*}"
        local host="''${target#*@}"

        if [[ -z "$user" || -z "$host" || "$target" != *@* ]]; then
          echo "Usage: sshw user@host [command...]" >&2
          return 1
        fi

        local pass
        pass=$(secret-tool lookup user "$user" service rc-coremedia2)

        if [[ -z "$pass" ]]; then
          echo "No password found for user '$user' in service 'rc-coremedia2'" >&2
          echo "Store with: secret-tool store --label='RC $user' user $user service rc-coremedia2" >&2
          return 1
        fi

        sshpass -p "$pass" ssh \
          -o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o PreferredAuthentications=password \
          -o PubkeyAuthentication=no \
          "''${user}@''${host}" "$@"
      }

      # Tab completion for sshw (zsh)
      _sshw() {
        local users_file="''${XDG_CONFIG_HOME:-$HOME/.config}/sshw/users"
        local hosts_file="''${XDG_CONFIG_HOME:-$HOME/.config}/sshw/hosts"
        local cur="$PREFIX"

        if [[ "$cur" == *@* ]]; then
          # After @, complete hosts
          local user="''${cur%@*}"
          local hosts=()
          [[ -f "$hosts_file" ]] && hosts=("''${(@f)$(< "$hosts_file")}")
          local -a completions
          for h in "''${hosts[@]}"; do
            completions+=("''${user}@''${h}")
          done
          compadd -S "" -- "''${completions[@]}"
        else
          # Before @, complete users (with @ suffix)
          local users=()
          [[ -f "$users_file" ]] && users=("''${(@f)$(< "$users_file")}")
          local -a completions
          for u in "''${users[@]}"; do
            completions+=("''${u}@")
          done
          compadd -S "" -- "''${completions[@]}"
        fi
      }

      compdef _sshw sshw
    '';
  };
}
