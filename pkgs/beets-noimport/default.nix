{ lib
, fetchFromGitLab
, beets
, python3Packages
,
}:
python3Packages.buildPythonApplication rec {
  pname = "beets-noimport";
  version = "0.1.0b5";

  src = fetchFromGitLab {
    repo = pname;
    owner = "tiago.dias";
    rev = "v${version}";
    hash = "sha256-7N7LiOdDZD/JIEwx7Dfl58bxk4NEOmUe6jziS8EHNcQ=";
  };

  # there are no tests
  doCheck = false;

  nativeBuildInputs = [ beets ];

  meta = with lib; {
    description = ''Add directories to the incremental import "do not import" list'';
    homepage = "https://gitlab.com/tiago.dias/beets-noimport";
    maintainers = with maintainers; [ somasis ];
    license = licenses.mit;
  };
}
