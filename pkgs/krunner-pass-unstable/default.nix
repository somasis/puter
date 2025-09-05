{
  lib,
  fetchFromGitHub,
  fetchpatch,
  pass,
  stdenv,
  cmake,
  kdePackages,
}:
let
  inherit (kdePackages)
    extra-cmake-modules
    kauth
    krunner
    wrapQtAppsHook
    qtbase

    kservice
    ktextwidgets
    kconfigwidgets
    knotifications
    kcmutils
    kguiaddons
    libplasma
    ;
in
stdenv.mkDerivation rec {
  pname = "krunner-pass-unstable";
  # when upgrading the version, check if cmakeFlags is still needed
  version = "1.3.0-unstable-2024-04-24";

  src = fetchFromGitHub {
    owner = "akermu";
    repo = "krunner-pass";
    rev = "b1a929b008b5ce9dd35b6d31741bf5215fd06434";
    hash = "sha256-tGAYUFPxM4hXEiWuhT2g4u0WPWRVXDbKKN5av6FEhe8=";
  };

  buildInputs = [
    kauth
    krunner
    (pass.withExtensions (p: with p; [ pass-otp ]))
    wrapQtAppsHook
    qtbase
    kservice
    ktextwidgets
    kconfigwidgets
    knotifications
    kcmutils
    kguiaddons
    libplasma
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  patches = [
    ./pass-path.patch
  ];

  CXXFLAGS = [
    ''-DNIXPKGS_PASS=\"${lib.getBin pass}/bin/pass\"''
  ];

  cmakeFlags = [
    # there are *lots* of pointless warnings in v1.3.0
    # "-Wno-dev"
    # required for kf5auth to work correctly
    # "-DCMAKE_POLICY_DEFAULT_CMP0012=NEW"
    "-DQT_MAJOR_VERSION=6"
  ];

  meta = with lib; {
    description = "Integrates krunner with pass the unix standard password manager (https://www.passwordstore.org/)";
    homepage = "https://github.com/akermu/krunner-pass";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ysndr ];
    platforms = platforms.unix;
  };
}
