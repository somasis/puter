{ lib
, buildPythonApplication
, fetchFromSourcehut
, setuptools
, cssselect
, lxml
, pyrss2gen
, python-dateutil
, requests
,
}:
buildPythonApplication rec {
  pname = "newslinkrss";
  version = "0.12.0";
  pyproject = true;

  src = fetchFromSourcehut {
    owner = "~ittner";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cIGWnX5rSWu/BKxJTYz+e4P56AnI0RqApAb8CWSXsvg=";
  };

  propagatedBuildInputs = [
    setuptools
    cssselect
    lxml
    pyrss2gen
    python-dateutil
    requests
  ];

  meta = with lib; {
    description = "Create RSS feeds for sites that don't provide them";
    homepage = "https://git.sr.ht/~ittner/newslinkrss";
    license = [ licenses.gpl3Plus ];
  };
}
