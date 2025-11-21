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

    # Auto-install Navigator plugin if missing
    activation.claudeCodePlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run=${pkgs.writeShellScript "claude-plugins" ''
        # Source profile to get PATH
        [ -f "$HOME/.profile" ] && . "$HOME/.profile"
        [ -f "$HOME/.zshenv" ] && . "$HOME/.zshenv"

        if ! command -v claude &>/dev/null; then
          echo "claude CLI not found, skipping plugin setup"
          exit 0
        fi

        plugins_file="$HOME/.claude/plugins/installed_plugins.json"

        # Check if Navigator plugin is installed
        if [ ! -f "$plugins_file" ] || \
           ! ${pkgs.jq}/bin/jq -e '.plugins["navigator@navigator-marketplace"]' "$plugins_file" &>/dev/null; then
          echo "Adding Navigator marketplace..."
          claude plugin marketplace add alekspetrov/navigator || true
          echo "Installing Navigator plugin..."
          claude plugin install navigator@navigator-marketplace || true
        fi
      ''}
      $DRY_RUN_CMD $run
    '';
  };
}
