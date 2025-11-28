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
make           # Apply configuration (default)
make upgrade   # Update flake inputs and apply
make help      # Show all targets
```

## External Dependencies

Some packages are installed externally with HM-managed config.
See [EXTERNAL-DEPENDENCIES.md](EXTERNAL-DEPENDENCIES.md).

<details>
<summary>Managed Tools & Programs</summary>

**Shell & Terminal**
- zsh (with autosuggestions, syntax-highlighting)
- tmux (with resurrect plugin)
- fzf (fuzzy finder)
- zoxide (smart cd)
- lsd (modern ls)

**Nix Tools**
- nil (LSP)
- nixpkgs-fmt (formatter)
- statix (linter)

**Development**
- neovim
- lazygit
- delta (git diff viewer)
- ripgrep, fd
- jq, yq-go
- asdf-vm

**Kubernetes & AWS**
- k9s
- aws-iam-authenticator
- grpcui, grpcurl

**Claude Code**
- Custom commands, skills, hooks (declaratively managed)
- Navigator plugin auto-install

</details>
