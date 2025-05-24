{ stdenv
, lib
, fetchFromGitHub
, cmake
, nlohmann_json
, kdePackages
,
}:
kdePackages.mkKdeDerivation rec {
  pname = "krunner-zotero-unstable";
  version = "0.1.0-unstable-2024-10-28";

  src = fetchFromGitHub {
    owner = "tran-khoa";
    repo = "krunner-zotero";
    rev = "b53ddbff5cc02e1290e5ea940a3d056ef29fa838";
    hash = "sha256-ClpgFQj3ymOeKD6gcCXIEqgHy/JPb4Apu0xVVVNJ1GI=";
  };

  extraBuildInputs = with kdePackages; [
    qtbase
    kio
    krunner
    nlohmann_json
  ];

  # extraNativeBuildInputs = with kdePackages; [
  #   extra-cmake-modules
  # ];

  meta = with lib; {
    description = "Zotero search plugin for KRunner";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    inherit (kdePackages.krunner.meta) platforms;
  };
}
