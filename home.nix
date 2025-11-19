{ lib, pkgs, ... }:
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

    username = "aleksandr-kiusev";
    homeDirectory = "/home/aleksandr-kiusev";

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
