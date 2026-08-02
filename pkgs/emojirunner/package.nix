{
  lib,
  fetchFromGitHub,
  kdePackages,
}:
kdePackages.mkKdeDerivation rec {
  pname = "emojirunner";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "alex1701c";
    repo = "EmojiRunner";
    rev = version;
    hash = "sha256-bATM93BreumyKbyYwPZ8nXL44B3sfSPn7Ob6qHcbGhY=";
  };

  extraBuildInputs = with kdePackages; [
    qtbase
    kcmutils
    krunner
  ];

  extraNativeBuildInputs = with kdePackages; [
    extra-cmake-modules
  ];

  extraCmakeFlags = [
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
  ];

  meta = with lib; {
    description = "Emoji search plugin for KRunner";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ somasis ];
    inherit (kdePackages.krunner.meta) platforms;
  };
}
