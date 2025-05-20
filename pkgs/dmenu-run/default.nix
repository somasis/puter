{ lib
, writeShellApplication
, coreutils
, dmenu
, findutils
, gawk
, gnugrep
, gnused
, libnotify
, moreutils
, systemd
}:
writeShellApplication {
  name = "dmenu-run";

  runtimeInputs = [
    coreutils
    dmenu
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    moreutils
    systemd
  ];

  text = builtins.readFile ./dmenu-run.bash;

  meta = with lib; {
    description = "An application runner that uses dmenu";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
