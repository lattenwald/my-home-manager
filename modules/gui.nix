# GUI-specific configuration
# Only applied when ~/.gui-machine marker file exists
{ config, lib, pkgs, ... }:
let
  homeDirectory = builtins.getEnv "HOME";
  isGuiMachine = builtins.pathExists "${homeDirectory}/.gui-machine";

  # Shared regex patterns for alacritty hints
  # Double backslashes for TOML escaping: \\ in Nix ''...'' → \\ in TOML → \ for regex
  filePathRegex = ''[a-zA-Z0-9_/-]+(\\.[a-zA-Z0-9_/-]+)+(:[0-9]+)?(?-u:\\b)'';
  # Simplified URL regex - avoids complex unicode ranges
  urlRegex = ''(mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\\s<>"]+'';
  erlangPidRegex = ''<[0-9]+\\.[0-9]+\\.[0-9]+>'';
in
lib.mkIf isGuiMachine {
  home.packages = with pkgs; [
    shikane # Wayland display manager (config kept local - machine-specific)
    swaynotificationcenter # Notification daemon
  ];

  home.file.".local/bin/gammastep-update-location" = {
    source = ../scripts/gammastep-update-location.sh;
    executable = true;
  };

  # SwayNC style (Catppuccin theme)
  xdg.configFile."swaync/style.css".source = ../files/swaync/style.css;

  programs.alacritty = {
    enable = true;
    package = pkgs.emptyDirectory; # Use system alacritty, just manage config
    settings = {
      colors = {
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "#0D303A";
          foreground = "#ffffff";
        };
        normal = {
          black = "#111111";
          red = "#ed3146";
          green = "#3eb34e";
          yellow = "#dfb920";
          blue = "#19b6ee";
          magenta = "#b33ea2";
          cyan = "#31edd8";
          white = "#c1c1c1";
        };
        bright = {
          black = "#3b3b3b";
          red = "#f05a6a";
          green = "#64c272";
          yellow = "#edc74c";
          blue = "#46c4f1";
          magenta = "#c264b4";
          cyan = "#5af0e9";
          white = "#ececec";
        };
        cursor = {
          cursor = "#839496";
          text = "#002b36";
        };
      };

      font = {
        size = 10.0;
        normal = {
          family = "DejaVu Sans Mono";
          style = "Regular";
        };
        bold = {
          family = "DejaVu Sans Mono";
          style = "Bold";
        };
        italic = {
          family = "DejaVu Sans Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "DejaVu Sans Mono";
          style = "Bold Italic";
        };
      };

      hints = {
        alphabet = "jfkdls;ahgurieowpq";
        enabled = [
          # File paths - Ctrl+click to open
          {
            regex = filePathRegex;
            command = "xdg-open";
            post_processing = true;
            mouse = { enabled = true; mods = "Control"; };
          }
          # File paths - Alt+click to copy
          {
            regex = filePathRegex;
            command = "wl-copy";
            post_processing = true;
            mouse = { enabled = true; mods = "Alt"; };
          }
          # URLs - Ctrl+click to open
          {
            regex = urlRegex;
            command = "xdg-open";
            post_processing = true;
            binding = { key = "U"; mods = "Control|Shift"; };
            mouse = { enabled = true; mods = "Control"; };
          }
          # URLs - Alt+click to copy
          {
            regex = urlRegex;
            command = "wl-copy";
            post_processing = true;
            binding = { key = "U"; mods = "Alt"; };
            mouse = { enabled = true; mods = "Alt"; };
          }
          # Erlang PID - Alt+click to copy
          {
            regex = erlangPidRegex;
            command = "wl-copy";
            post_processing = true;
            mouse = { enabled = true; mods = "Alt"; };
          }
        ];
      };

      keyboard.bindings = [
        { action = "Copy"; key = "Insert"; mods = "Control"; }
        { action = "Paste"; key = "Insert"; mods = "Shift"; }
      ];

      selection.save_to_clipboard = true;
      window.dynamic_title = true;
      general.live_config_reload = true;
    };
  };

  systemd.user.services.shikane = {
    Unit = {
      Description = "shikane - Wayland display configuration";
      After = [ "wayland.target" ];
      PartOf = [ "wayland.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.shikane}/bin/shikane";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "wayland.target" ];
    };
  };

  systemd.user.services.swaync = {
    Unit = {
      Description = "SwayNC notification daemon";
      After = [ "wayland.target" ];
      PartOf = [ "wayland.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config ; ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "wayland.target" ];
    };
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 41.7;
    longitude = 44.8;
    temperature = {
      day = 5500;
      night = 3700;
    };
    tray = false;
  };
}
