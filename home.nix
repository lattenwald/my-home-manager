{ lib, pkgs, ... }:
let
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
in
assert lib.assertMsg (username != "") "USER environment variable is not set";
assert lib.assertMsg (homeDirectory != "") "HOME environment variable is not set";
assert lib.assertMsg (builtins.pathExists homeDirectory) "Home directory ${homeDirectory} does not exist";
{
  imports = [
    ./modules/shell/zsh.nix
    ./modules/claude-code.nix
    ./modules/tmux.nix
    ./modules/git.nix
    ./modules/bash.nix
    ./modules/shell/starship.nix
    ./modules/gui.nix
    ./modules/ssh.nix
    ./modules/work.nix
  ];

  home = {
    packages = with pkgs; [
      hello
      cowsay
      lolcat

      nil
      nixpkgs-fmt
      statix

      asdf-vm
      bat
      csvlens
      dua
      duf
      fd
      grpcui
      grpcurl
      k9s
      luarocks
      mdsh
      ripgrep
      selene
      trippy

      glow
      jq
      yq-go
      lazygit
      aws-iam-authenticator

      luajitPackages.jsregexp

      keychain

      zsh-completions
    ];

    inherit username homeDirectory;

    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    home-manager.enable = true;

    neovim = {
      enable = true;
      extraLuaPackages = ps: [
        ps.lyaml
        ps.xml2lua
        ps.mimetypes
        ps.jsregexp
      ];
    };

    readline = {
      enable = true;
      variables = {
        meta-flag = true;
        input-meta = true;
        convert-meta = false;
        output-meta = true;
      };
      bindings = {
        "\\e[5~" = "history-search-backward";
        "\\e[6~" = "history-search-forward";
        "\\e[1~" = "beginning-of-line";
        "\\e[4~" = "end-of-line";
        "\\e[1;5C" = "forward-word";
        "\\e[1;5D" = "backward-word";
        "\\e[5C" = "forward-word";
        "\\e[5D" = "backward-word";
        "\\e\\e[C" = "forward-word";
        "\\e\\e[D" = "backward-word";
      };
    };
  };
}
