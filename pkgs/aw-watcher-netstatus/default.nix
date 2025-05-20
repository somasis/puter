{ lib
, python3
, fetchFromGitHub
,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "aw-watcher-netstatus";
  version = "unstable-2023-01-31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sameersismail";
    repo = "aw-watcher-netstatus";
    rev = "99f17662209150f6c43ec6c3ec3e256b4c4ea6ea";
    hash = "sha256-aE2hcUgPir99fdkzaZoIUoUqfQXOlTTJvBHAtsR0j48=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aw-client
    aw-core
  ];

  pythonImportsCheck = [ "aw_watcher_netstatus" ];

  meta = with lib; {
    description = "ActivityWatch monitor for observing the network connection status";
    homepage = "https://github.com/sameersismail/aw-watcher-netstatus";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "aw-watcher-netstatus";
  };
}
