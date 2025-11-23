{ config, lib, pkgs, ... }:

{
  # Claude Code user configuration
  # Manages: commands, skills, hooks, CLAUDE.md
  # Does NOT manage: credentials, settings.json, plugins, runtime state

  home = {
    file = {
      # Custom slash commands
      ".claude/commands" = {
        source = ../claude/commands;
        recursive = true;
      };

      # Custom skills
      ".claude/skills" = {
        source = ../claude/skills;
        recursive = true;
      };

      # Hook scripts
      ".claude/hooks" = {
        source = ../claude/hooks;
        recursive = true;
      };

      # Global instructions
      ".claude/CLAUDE.md".source = ../claude/CLAUDE.md;
    };

    # Ensure runtime directories exist (contents not managed)
    activation.claudeCodeDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ~/.claude/{todos,projects,session-env,file-history,debug,plugins,plans,ide,statsig}
    '';

    # Auto-install Claude Code plugins
    activation.claudeCodePlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run=${pkgs.writeShellScript "claude-plugins" ''
        set -eo pipefail

        # Source profile to get PATH (without -u to avoid bashrc issues)
        [ -f "$HOME/.profile" ] && . "$HOME/.profile" || true
        [ -f "$HOME/.zshenv" ] && . "$HOME/.zshenv" || true

        if ! command -v claude &>/dev/null; then
          echo "claude CLI not found, skipping plugin setup"
          exit 0
        fi

        # Define paths and ensure base directory exists
        plugins_dir="$HOME/.claude/plugins"
        plugins_file="$plugins_dir/installed_plugins.json"
        marketplaces_file="$plugins_dir/known_marketplaces.json"
        mkdir -p "$plugins_dir"

        # Helper function to ensure a plugin is installed idempotently
        ensure_plugin_installed() {
          marketplace_repo="$1"       # e.g., "obra/superpowers-marketplace"
          marketplace_name="$2"       # e.g., "superpowers-marketplace"
          plugin_id="$3"              # e.g., "superpowers@superpowers-marketplace"

          # Check if plugin is already installed
          if [ -f "$plugins_file" ] && ${pkgs.jq}/bin/jq -e --arg id "$plugin_id" '.plugins[$id]' "$plugins_file" >/dev/null 2>&1; then
            echo "Plugin '$plugin_id' is already installed. Skipping."
            return 0
          fi

          echo "Installing plugin '$plugin_id'..."

          # Add marketplace if not present
          if [ ! -f "$marketplaces_file" ] || ! ${pkgs.jq}/bin/jq -e --arg name "$marketplace_name" '.[$name]' "$marketplaces_file" >/dev/null 2>&1; then
            echo "--> Adding marketplace '$marketplace_repo'."
            claude plugin marketplace add "$marketplace_repo"
          else
            echo "--> Marketplace '$marketplace_name' already added."
          fi

          echo "--> Installing plugin '$plugin_id'."
          claude plugin install "$plugin_id"

          echo "--> Successfully installed '$plugin_id'."
        }

        # Install plugins
        ensure_plugin_installed "alekspetrov/navigator" "navigator-marketplace" "navigator@navigator-marketplace"
        ensure_plugin_installed "obra/superpowers-marketplace" "superpowers-marketplace" "superpowers@superpowers-marketplace"

        echo "Claude plugin setup complete."
      ''}
      $DRY_RUN_CMD $run
    '';
  };
}
