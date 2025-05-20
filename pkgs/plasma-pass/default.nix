{ stdenv
, lib
, fetchFromGitLab
, cmake
, oath-toolkit
, kdePackages
,
}:

stdenv.mkDerivation rec {
  pname = "plasma-pass";
  version = "unstable-2025-02-08";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "plasma-pass";
    rev = "394ef5e06c21a706cab9a2c34b6d81460aa74d07";
    hash = "sha256-5JTo+jr9flsZcj3K3Biht/uZq8CUEqhIoJ+ucSBiEDM=";
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
    maintainers = with maintainers; [ matthiasbeyer ];
    platforms = platforms.unix;
  };
}
