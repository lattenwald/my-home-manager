# My Home Manager - Development Documentation

**Project**: My Home Manager
**Type**: Nix/Home Manager Configuration
**Tech Stack**: Nix Flakes, Home Manager, Zsh
**Initialized**: 2025-11-20

## Overview

This is a declarative Home Manager configuration for managing user environment, shell configuration, and packages across systems. The configuration uses Nix flakes for reproducibility and supports dynamic user detection for portability.

## Key Components

- **flake.nix**: Flake configuration defining inputs (nixpkgs, home-manager) and outputs
- **home.nix**: Main Home Manager configuration with packages and program settings
- **modules/shell/zsh.nix**: Comprehensive Zsh configuration module
- **modules/shell/zsh-aliases.nix**: Shell aliases (55+ aliases)
- **modules/shell/zsh-functions.nix**: Custom shell functions
- **Makefile**: Convenience commands for updating, upgrading, formatting, and linting

## Architecture

### Configuration Structure
```
.
├── flake.nix                    # Flake definition
├── flake.lock                   # Locked dependencies
├── home.nix                     # Main configuration
├── modules/
│   └── shell/
│       ├── zsh.nix             # Zsh configuration
│       ├── zsh-aliases.nix     # Shell aliases
│       └── zsh-functions.nix   # Custom functions
├── Makefile                     # Build/maintenance commands
└── .agent/                      # Navigator documentation
```

### Dynamic User Detection

The configuration uses `builtins.getEnv` with the `--impure` flag to detect:
- Current username from `$USER`
- Home directory from `$HOME`

This makes the configuration portable across different users and systems.

## Development Workflow

### Common Commands

```bash
make update   # Apply home-manager configuration
make upgrade  # Update flake inputs and apply changes
make fmt      # Format all .nix files with nixpkgs-fmt
make lint     # Lint all .nix files with statix
make clean    # Run garbage collection
make help     # Show all available targets
```

### Making Changes

1. **Edit configuration files** (home.nix, modules/*)
2. **Format code**: `make fmt`
3. **Lint code**: `make lint`
4. **Apply changes**: `make update`
5. **Commit**: Use git to track changes

### Adding New Packages

Add packages to `home.packages` in home.nix:

```nix
home.packages = with pkgs; [
  # Your packages here
  new-package
];
```

Then run `make update` to apply.

### Adding New Modules

1. Create module file in `modules/` directory
2. Add import in home.nix:
   ```nix
   imports = [
     ./modules/your-module.nix
   ];
   ```
3. Apply with `make update`

## Tech Stack Details

### Nix & Home Manager

- **Nix Version**: Managed via flake inputs (nixpkgs/nixos-25.05)
- **Home Manager**: Release 25.05
- **State Version**: 25.05

### Packages

Core development tools:
- **Neovim**: Text editor with Lua package support
- **Nix Tools**: nil (LSP), nixpkgs-fmt (formatter), statix (linter)
- **Shell**: Zsh with autosuggestions and syntax highlighting
- **Version Managers**: asdf-vm
- **Utilities**: duf, grpcui, grpcurl, k9s, lazygit, glow

### Shell Configuration

The Zsh configuration includes:
- **Completion system**: Custom paths, fuzzy matching, case-insensitive
- **History**: 2000 entries, deduplication, append mode
- **Plugins**: autosuggestions, syntax-highlighting (via home-manager)
- **Prompt**: VCS info with git status, SSH detection, colorized
- **Keybindings**: Emacs mode with custom terminal key mappings
- **Environment**: Comprehensive PATH setup, tool-specific completions

## Testing

### Manual Testing

After making changes:
1. Run `make lint` to check for issues
2. Run `make update` to apply (creates backup if needed)
3. Open new terminal to test shell changes
4. Verify package availability

### Rollback

If something breaks:
```bash
home-manager generations  # List previous generations
home-manager switch --rollback  # Rollback to previous
```

## Navigator Workflow

### Task Management

Create task documentation for new features:
```
"Create task for adding new package"
```

Tasks are stored in `.agent/tasks/` as markdown files.

### Session Start

Begin work session:
```
"Start my Navigator session"
```

Loads context from DEVELOPMENT-README.md and checks for active tasks.

### Standard Procedures

Document recurring procedures in `.agent/sops/`:
- **integrations/**: External tool setup
- **debugging/**: Troubleshooting guides
- **development/**: Development workflows
- **deployment/**: Release processes

### Context Management

- **Save progress**: `"Create checkpoint"` or `"Save my progress"`
- **Clear context**: `"Clear context"` or `"Start fresh"`
- **Resume work**: Context automatically restored

## Troubleshooting

### Common Issues

**Configuration fails to apply**:
- Check for syntax errors: `make lint`
- Verify file paths are correct
- Ensure modules are git-tracked (flakes requirement)

**Packages not available**:
- Run `make update` to apply changes
- Check package name in nixpkgs
- Verify PATH includes nix profile directories

**Shell changes not taking effect**:
- Open new terminal after `make update`
- Check for errors in zsh configuration
- Verify `~/.zshrc` is symlinked to nix store

**Flake can't find files**:
- Add new files to git: `git add <file>`
- Flakes only see git-tracked files

### Debugging

Enable debug output:
```bash
home-manager switch --impure --flake .#myProfile --show-trace
```

Check home-manager logs:
```bash
journalctl --user -u home-manager-aleksandr-kiusev.service
```

## Best Practices

1. **Always format before committing**: `make fmt`
2. **Run linter regularly**: `make lint`
3. **Test changes incrementally**: Apply small changes with `make update`
4. **Use git tracking**: Commit configuration changes
5. **Document complex changes**: Update this README or create SOPs
6. **Modular organization**: Keep related config in separate modules
7. **Declarative packages**: Avoid imperative `nix-env -i`, use home.packages

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://mynixos.com/home-manager/options)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Contributing

This is a personal configuration, but feel free to use as reference or template.

## License

Personal configuration - use as you see fit.
