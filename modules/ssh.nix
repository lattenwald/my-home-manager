_:
{
  # SSH config managed via file symlinks
  home.file.".ssh/config".source = ../files/ssh/config;
  xdg.configFile."ssh/config_personal".source = ../files/ssh/config_personal;
}
