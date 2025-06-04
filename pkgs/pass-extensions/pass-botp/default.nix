{ lib
, stdenvNoCC
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation rec {
  pname = "pass-botp";
  version = "1.0.1";

  src = fetchFromGitHub {
    repo = "pass-botp";
    owner = "msmol";
    rev = "v${version}";
    hash = "sha256-oI5Vrb3G+9B+sknGsG5V85syF2HK7rJwtFUTGG1w6Cg=";
  };

  installPhase = ''
    install -D -m755 $src/src/botp.bash $out/lib/password-store/extensions/botp.bash
  '';
}
