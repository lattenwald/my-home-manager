# Home Manager Configuration

## Install Nix

**Any Linux:**
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

## Install Home Manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

**Add to `.bashrc` or `.zshrc`:**
```bash
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

## Usage

```bash
make update   # Apply configuration
make upgrade  # Update packages and apply
make fmt      # Format .nix files
make clean    # Run garbage collection
make help     # Show all targets
```
