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
      delta
      duf
      fd
      grpcui
      grpcurl
      k9s
      luarocks
      ripgrep

      glow
      jq
      yq-go
      lazygit
      aws-iam-authenticator

      luajitPackages.jsregexp

      keychain
    ];

    inherit username homeDirectory;

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;

    extraLuaPackages = ps: [
      ps.lyaml
      ps.xml2lua
      ps.mimetypes
      ps.jsregexp
    ];
  };
}
