{
  lib,
  fetchFromGitHub,
  kdePackages,
}:
kdePackages.mkKdeDerivation rec {
  pname = "plasma-applet-appgrid";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "xarbit";
    repo = "plasma6-applet-appgrid";
    rev = "v${version}";
    hash = "sha256-N5o1fFcnQ074P4MoGWA3rmJOFmFjE+cU2op0EGsOxIg=";
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
