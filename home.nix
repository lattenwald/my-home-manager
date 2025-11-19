{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      hello
      cowsay
      lolcat

      nixpkgs-fmt

      asdf-vm
      duf
      grpcui
      grpcurl
      k9s
      luarocks
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
    ];

    extraPackages = with pkgs; [
      luajitPackages.lyaml
      nil
    ];
  };
}
