{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
}:
let
  inherit (kdePackages) kwin;
in
stdenv.mkDerivation rec {
  pname = "kwin-switch-to-last-used-desktop";
  version = "unstable-2025-12-26";

  src = fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "kwin-switch-to-last-used-desktop";
    rev = "20b2713460bed432c68359da304a83655fa2113d";
    hash = "sha256-580/klIqfiZWRyy3UNNx/NHsp4bsbCbFvoJzepOlPNQ=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.kpackage
    kdePackages.extra-cmake-modules
    kdePackages.kcoreaddons.dev
    kdePackages.qtbase
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_SCRIPT" true)
  ];

  meta = {
    description = "A KWin script to switch to the last used virtual desktop";
    homepage = "https://github.com/luisbocanegra/kwin-switch-to-last-used-desktop";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "kwin-switch-to-last-used-desktop";
    platforms = kwin.meta.platforms;
  };
}
