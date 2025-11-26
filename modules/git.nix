{ lib, ... }:
let
  homeDirectory = builtins.getEnv "HOME";
  isWorkMachine = builtins.pathExists "${homeDirectory}/.work-machine";
in
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    # All settings go under programs.git.settings (new HM structure)
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

      # GitHub credential helper
      "credential \"https://github.com\"".helper = "!gh auth git-credential";
      "credential \"https://gist.github.com\"".helper = "!gh auth git-credential";
    } // lib.optionalAttrs isWorkMachine {
      # Work-specific URL rewriting
      "url \"git@git.ringcentral.com:\"".insteadOf = "https://git.ringcentral.com/";
    };
  };

  # Delta pager (separate module in new HM)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = false;
    };
  };
}
