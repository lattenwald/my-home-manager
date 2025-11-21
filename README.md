# Home Manager Configuration

## Install Nix

**Any Linux:**
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

## Setup

```bash
git clone <this-repo> ~/my-home-manager
cd ~/my-home-manager
make install   # First-time bootstrap
```

## Usage

```bash
make update   # Apply configuration
make upgrade  # Update packages and apply
make fmt      # Format .nix files
make lint     # Lint .nix files
make clean    # Run garbage collection
make help     # Show all targets
```
