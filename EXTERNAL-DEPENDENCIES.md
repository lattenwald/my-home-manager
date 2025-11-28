# External Dependencies

Packages installed outside Home Manager (system/cargo) with HM-managed config.

## GUI Applications

### alacritty

GPU-accelerated terminal. Nix version has Wayland/EGL issues.

**Install:**
```bash
cargo install alacritty
```

**HM config:** `programs.alacritty` with `package = pkgs.emptyDirectory`

## Console Applications

*None currently.*

---

<details>
<summary>Adding new entries</summary>

```nix
programs.<pkg> = {
  enable = true;
  package = pkgs.emptyDirectory;  # config-only
  settings = { ... };
};
```

</details>
