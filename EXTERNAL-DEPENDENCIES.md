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

### sway / swayidle / swaylock / waybar

Wayland compositor stack. System packages integrate better with XDG portals, polkit, dbus on non-NixOS.

**Config:** `~/.config/sway/`, `~/.config/waybar/`, `~/.config/systemd/user/swayidle.service`

### pavucontrol

PulseAudio/PipeWire volume control. GTK app with system audio integration.

### asusctl / supergfxctl

ASUS laptop control (ROG features, GPU switching). Requires system service and kernel modules.

## Console Applications

### secret-tool (libsecret)

CLI for GNOME Keyring / Secret Service. Used by `rcsh` function for password retrieval.

**Install:**
- Ubuntu/Debian: `apt install libsecret-tools`
- Arch: `pacman -S libsecret`

**Usage:** `secret-tool store/lookup` - no HM config needed

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
