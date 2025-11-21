{
  # File utilities
  df = "duf";
  dir = "dir --color=auto";
  vdir = "vdir --color=auto";
  cpr = "rsync -a --human-readable --progress";
  ff = "fd -IH";

  # Text processing
  grep = "grep --color=auto";
  fgrep = "grep -F --color=auto";
  egrep = "grep -E --color=auto";

  # System utilities
  watch = "watch --color";
  pacman = "pacman --color auto";
  pactree = "pactree --color";
  ports = "ss -lptun";
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
  gg = "lazygit";

  # Docker
  d = "docker compose";

  # Misc
  help = "run-help";
}
