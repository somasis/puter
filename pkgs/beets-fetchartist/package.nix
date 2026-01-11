# NOTE I can't recall if this actually works!
{
  lib,
  fetchFromGitHub,
  beets,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "beets-fetchartist";
  version = "unstable-2020-07-03";

  format = "other";

  src = fetchFromGitHub {
    repo = pname;
    owner = "dkanada";
    rev = "6ab1920d2ae217bf1c814cdeab220e6d09251aac";
    hash = "sha256-jPm4S02VOYuUgA3wSHX/gdhWIZXZ1k+yLnbui5J/VuU=";
  };

  propagatedBuildInputs = with python3Packages; [
    pylast
    requests
  ];

  nativeBuildInputs = [ beets ];

  installPhase = ''
    beetsplug=$(toPythonPath "$out")/beetsplug
    mkdir -p $beetsplug
    cp -r $src/beetsplug/* $beetsplug/
  '';

  meta = with lib; {
    description = "Artist images for beets";
    homepage = "https://github.com/dkanada/beets-fetchartist";
    maintainers = with maintainers; [ somasis ];
    license = licenses.mit;
  };
}
