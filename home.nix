{ lib, pkgs, ... }:
{
    home = {
        packages = with pkgs; [
            hello
        ];

        username = "aleksandr-kiusev";
        homeDirectory = "/home/aleksandr-kiusev";

        stateVersion = "25.05";
    };
}
