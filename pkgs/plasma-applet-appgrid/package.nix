{
  lib,
  fetchFromGitHub,
  kdePackages,
}:
kdePackages.mkKdeDerivation rec {
  pname = "plasma-applet-appgrid";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "xarbit";
    repo = "plasma6-applet-appgrid";
    rev = "v${version}";
    hash = "sha256-3JZqyTcpX6/DUKai2qOlToBnt8rXHN/avPdFYPDWjek=";
  };

  extraBuildInputs = with kdePackages; [
    plasma-desktop
    qtdeclarative
    extra-cmake-modules
  ];

  meta = with lib; {
    description = "Grid-centered application launcher";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ somasis ];
    inherit (kdePackages.krunner.meta) platforms;
  };
}
