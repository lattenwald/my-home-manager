# Claude Code Instructions for My Home Manager

## Project Overview

This is a declarative Home Manager configuration using Nix flakes. The configuration manages user environment, shell setup (Zsh), and packages across systems with dynamic user detection for portability.

## Navigator Workflow

### Starting a Session

When starting work on this project:
1. Read `.agent/DEVELOPMENT-README.md` for current state
2. Check `.agent/tasks/` for active tasks
3. Review git status to see uncommitted work

### Task Management

- **Create tasks**: "Create task for [feature/bug/refactor]"
- **List tasks**: "Show my tasks"
- **Archive completed**: "Archive completed tasks"

Tasks are stored in `.agent/tasks/` as markdown with implementation plans.

### Standard Procedures (SOPs)

Document recurring procedures in `.agent/sops/`:
- **integrations/**: Setting up external tools
- **debugging/**: Troubleshooting common issues
- **development/**: Development workflows
- **deployment/**: Release processes

Create SOP: "Document this solution" or "Create SOP for [topic]"

### Context Management

- **Save checkpoint**: "Create checkpoint" before risky changes
- **Clear context**: "Clear context" when switching tasks
- **Resume work**: Context automatically restored from markers

## Development Guidelines

### Git Workflow

**IMPORTANT**: Never use `git add` or `git stage` commands automatically. Always ask the user before staging files.

When changes are ready to commit:
1. Show `git status` and `git diff --stat` to the user
2. Ask which files should be staged
3. Wait for user to stage files manually or give explicit permission

### Code Quality

1. **Always format before committing**: `make fmt`
2. **Always lint before committing**: `make lint`
3. **Test incrementally**: Use `make update` after each change
4. **Commit frequently**: Track configuration changes in git

### Nix/Home Manager Specifics

- **Flakes only see git-tracked files**: New modules must be git-tracked before testing (user handles staging)
- **Use --impure flag**: Required for dynamic user detection via `builtins.getEnv`
- **Prefer declarative**: Add packages to `home.packages`, not imperative `nix-env -i`
- **Modular organization**: Keep related config in separate module files

### Configuration Changes

When modifying configuration:
1. Edit files (home.nix, modules/*)
2. Format: `make fmt`
3. Lint: `make lint`
4. Apply: `make update`
5. Test in new terminal
6. Commit changes

### Adding Packages

Add to `home.packages` in home.nix:
```nix
home.packages = with pkgs; [
  new-package
];
```

### Creating Modules

1. Create file in `modules/` directory
2. Import in home.nix:
   ```nix
   imports = [
     ./modules/your-module.nix
   ];
   ```
3. Ask user to git-track the new file (required for flakes)
4. Apply with `make update`

### Machine-Type Markers

This config uses marker files for conditional configuration:

| Marker File | Purpose | Makefile Target |
|-------------|---------|-----------------|
| `~/.gui-machine` | Enable GUI apps/services | `make gui` / `make nogui` |
| `~/.work-machine` | Enable work-specific configs | `make work` / `make nowork` |

Detection pattern in Nix:
```nix
let
  homeDirectory = builtins.getEnv "HOME";
  isGuiMachine = builtins.pathExists "${homeDirectory}/.gui-machine";
in
lib.mkIf isGuiMachine { ... }
```

### Systemd User Services

GUI services are managed in `modules/gui.nix` using `systemd.user.services`.

**Important**: Use `wayland.target` (not `graphical-session.target`) - this is the active target on this system.

Example service definition:
```nix
systemd.user.services.example = {
  Unit = {
    Description = "Example service";
    After = [ "wayland.target" ];
    PartOf = [ "wayland.target" ];
  };
  Service = {
    Type = "simple";
    ExecStart = "${pkgs.example}/bin/example";
    Restart = "on-failure";
    RestartSec = 5;
  };
  Install = {
    WantedBy = [ "wayland.target" ];
  };
};
```

**Migrating manual services**:
1. Stop and disable: `systemctl --user stop <service> && systemctl --user disable <service>`
2. Remove old file: `rm ~/.config/systemd/user/<service>.service`
3. Add to `gui.nix`
4. Run `make update`

## Troubleshooting

### Common Issues

**Configuration fails to apply**:
- Check syntax: `make lint`
- Verify paths are correct
- Ensure modules are git-tracked

**Packages not available**:
- Run `make update` to apply
- Check PATH includes nix directories
- Verify package exists in nixpkgs

**Shell changes not working**:
- Open new terminal after update
- Check zsh module for errors
- Verify `~/.zshrc` symlink

**Flake can't find files**:
- Ask user to git-track new files
- Flakes require git tracking for all modules

### Debug Mode

Enable verbose output:
```bash
home-manager switch --impure --flake .#myProfile --show-trace
```

## Key Files

- **flake.nix**: Flake configuration (inputs, outputs)
- **home.nix**: Main Home Manager config (packages, programs)
- **modules/gui.nix**: GUI-specific config (conditional on `~/.gui-machine`)
- **modules/git.nix**: Git config (conditional work/personal email)
- **modules/shell/zsh.nix**: Zsh configuration
- **modules/shell/zsh-aliases.nix**: Shell aliases
- **modules/shell/zsh-functions.nix**: Custom functions
- **Makefile**: Convenience commands (update, upgrade, fmt, lint, clean, gui, work)

## Makefile Targets

```bash
make update   # Apply home-manager configuration
make upgrade  # Update flake inputs and apply
make fmt      # Format all .nix files
make lint     # Lint all .nix files
make clean    # Garbage collection
make gui      # Mark as GUI machine
make nogui    # Mark as non-GUI machine
make work     # Mark as work machine
make nowork   # Mark as personal machine
make help     # Show all targets
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://mynixos.com/home-manager/options)
- [NixOS Wiki](https://nixos.wiki/)
- Navigator documentation: `.agent/DEVELOPMENT-README.md`
