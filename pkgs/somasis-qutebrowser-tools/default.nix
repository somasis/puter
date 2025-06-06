{
  lib,
  symlinkJoin,
  writeShellApplication,
  coreutils,
  dateutils,
  sqlite,
}:
symlinkJoin {
  name = "somasis-qutebrowser-tools";

  paths = [
    (writeShellApplication {
      name = "qutebrowser-history-filter";

      runtimeInputs = [
        coreutils
        dateutils
        sqlite.bin
      ];

      text = builtins.readFile ./qutebrowser-history-filter.bash;
    })
  ];

  meta = with lib; {
    description = "Various tools for use with qutebrowser";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
