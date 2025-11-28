# GUI-specific configuration
# Only applied when ~/.gui-machine marker file exists
{ config, lib, pkgs, ... }:
let
  homeDirectory = builtins.getEnv "HOME";
  isGuiMachine = builtins.pathExists "${homeDirectory}/.gui-machine";
in
lib.mkIf isGuiMachine {
  home.packages = with pkgs; [
    shikane # Wayland display manager (config kept local - machine-specific)
  ];

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
}
