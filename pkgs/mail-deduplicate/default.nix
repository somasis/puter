{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  arrow,
  boltons,
  click,
  click-help-colors,
  click-log,
  poetry-core,
  sphinx,
  sphinx-rtd-theme,
  tabulate,
  tomlkit,
}:

buildPythonPackage rec {
  pname = "mail-deduplicate";
  version = "7.6.2";

  src = fetchFromGitHub rec {
    repo = pname;
    owner = "kdeldycke";
    hash = "sha256-gzFtZAXpn83F5yo8nbtAxyRUCB3/9GICIbdoWcXuEyk=";
    rev = "3af4b8274f1fc2d16946aac74c0d745836cae71a";
  };

  patches = [
    ./click-log.patch
  ];

  format = "pyproject";

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    arrow
    boltons
    click
    click-help-colors
    click-log
    sphinx
    sphinx-rtd-theme
    tabulate
    tomlkit
  ];

  meta = with lib; {
    homepage = "https://github.com/kdeldycke/mail-deduplicate";
    description = "command-line tool to deduplicate mails within a maildir";
    license = licenses.gpl2;
    maintainers = with maintainers; [ somasis ];
  };
}
