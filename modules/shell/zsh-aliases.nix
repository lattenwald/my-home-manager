{
  # File utilities
  df = "duf";
  ls = "lsd";
  dir = "dir --color=auto";
  vdir = "vdir --color=auto";
  cpr = "rsync -a --human-readable --progress";
  ff = "fd -IH";

  # Text processing
  grep = "grep --color=auto";
  fgrep = "fgrep --color=auto";
  egrep = "egrep --color=auto";

  # System utilities
  watch = "watch --color";
  pacman = "pacman --color auto";
  pactree = "pactree --color";
  ports = "netstat -lptun";
  colors = "for COLOR in {1..255}; do echo -en \"\\e[38;5;\${COLOR}m\${COLOR} \"; done; echo;";
  hwinfo = "for s in $(dmidecode --string 2>&1 | tail -n +4); do echo -en \"$s: \\t\";sudo dmidecode --string $s ; done";

  # Network utilities
  wanip = "dig +short myip.opendns.com @resolver1.opendns.com";
  wanip4 = "dig -4 +short myip.opendns.com @resolver1.opendns.com";
  wanip6 = "dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/^\"//;s/\"$//'";

  # SSH/SCP
  ssh_close = "ssh -O exit";
  scp = "/usr/bin/scp -o ControlMaster=no";

  # Editors
  vim = "nvim";
  v = "nvim";

  # Git
  dtf = "git --git-dir=\"$HOME/.dtf.git\" --work-tree=\"$HOME\"";
  gg = "lazygit";

  # Development tools
  sbtt = "sbt -sbt-version 0.12.4";
  pp = "perl -Iperl/api -Ilib";
  func = "print -l \${(ok)functions}";
  storable_show = "perl -MStorable -MJSON::XS -E 'say JSON::XS->new->pretty->encode(retrieve \\$ARGV[0])'";

  # Docker
  d = "docker compose";

  # Misc
  help = "run-help";

  # AWS login aliases with function call
  aws_login = "_aws_login_with_venv -l 898590214673 -u aleksandr.kiusev -r core-media-2";
  aws_login_hackathon = "_aws_login_with_venv -l 387917828062 -u aleksandr.kiusev -r team-aidea-031-role";
}
