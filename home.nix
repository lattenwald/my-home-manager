{ lib, pkgs, ... }:
let
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
in
assert lib.assertMsg (username != "") "USER environment variable is not set";
assert lib.assertMsg (homeDirectory != "") "HOME environment variable is not set";
assert lib.assertMsg (builtins.pathExists homeDirectory) "Home directory ${homeDirectory} does not exist";
{
  home = {
    packages = with pkgs; [
      hello
      cowsay
      lolcat

      nil
      nixpkgs-fmt

      asdf-vm
      duf
      grpcui
      grpcurl
      k9s
      luarocks

      glow
      lazygit
      aws-iam-authenticator

      luajitPackages.jsregexp
    ];

    inherit username homeDirectory;

    stateVersion = "25.05";
  };

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
