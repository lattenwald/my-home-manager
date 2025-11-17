{ lib, pkgs, ... }:
{
    home = {
        packages = with pkgs; [
            hello
            cowsay
            lolcat
        ];

        username = "aleksandr-kiusev";
        homeDirectory = "/home/aleksandr-kiusev";

        stateVersion = "25.05";
    };
}
