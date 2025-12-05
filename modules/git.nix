{ lib, pkgs, ... }:
let
  homeDirectory = builtins.getEnv "HOME";
  isWorkMachine = builtins.pathExists "${homeDirectory}/.work-machine";
in
{
  home.packages = [ pkgs.tig ];

  programs = {
    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user = {
          name = "Aleksandr Kiusev";
          email =
            if isWorkMachine
            then "aleksandr.kiusev@ringcentral.com"
            else "qalexx@gmail.com";
        };

        alias = {
          co = "checkout";
          ci = "commit";
          st = "status";
          br = "branch";
          ls = "ls-tree -r --name-only";
          undo = "reset --hard";
          undo-commit = "reset --soft HEAD^";
          unstage = "reset";
          wdiff = "diff --color-words";
          ndiff = "diff --name-only";
          tags = "tag -l";
          addremove = "!f() { git add -u && git add -A; };f";
          addre = "!f() { git add -u && git add -A; };f";
          l = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
          rpull = "submodule update --recursive --remote";
          rclone = "clone --recursive";
          pullall = "!f(){ git pull && git submodule update --init --recursive; }; f";
        };

        color.ui = "auto";
        push.default = "current";
        merge.tool = "kdiff3";
        github.user = "lattenwald";
        difftool.prompt = false;
        core.quotepath = false;
        credential.helper = "cache";
      } // lib.optionalAttrs isWorkMachine {
        "url \"git@git.ringcentral.com:\"".insteadOf = "https://git.ringcentral.com/";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = false;
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };

    lazygit = {
      enable = true;
      settings = {
        os = {
          edit = ''[ -z "$NVIM" ] && nvim -- {{filename}} || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})'';
          editAtLine = ''[ -z "$NVIM" ] && nvim +{{line}} -- {{filename}} || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote +{{line}} {{filename}})'';
        };
      };
    };
  };
}
