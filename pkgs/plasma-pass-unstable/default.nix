{
  stdenv,
  lib,
  fetchFromGitLab,
  cmake,
  oath-toolkit,
  kdePackages,
}:

stdenv.mkDerivation rec {
  pname = "plasma-pass-unstable";
  version = "1.2.2-unstable-2025-03-26";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-pass";
    rev = "d5ab4f68cd1f0ea722122617453ab953e26d4e11";
    hash = "sha256-1dG5TAAcQzDxtKvkASGYxtxsP6zPX7cLrQSDOgXgj8g=";
  };

  buildInputs = with kdePackages; [
    ki18n
    kio
    libplasma
    plasma5support
    kitemmodels
    oath-toolkit
    qgpgme
    qtbase
    qtdeclarative
  ];

  nativeBuildInputs = with kdePackages; [
    wrapQtAppsHook
    cmake
    extra-cmake-modules
  ];

  meta = with lib; {
    description = "Plasma applet to access passwords from pass, the standard UNIX password manager";
    homepage = "https://invent.kde.org/plasma/plasma-pass";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ somasis ];
    platforms = platforms.unix;
  };
}
