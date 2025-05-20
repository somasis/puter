{ lib
, stdenv
, fetchurl
, pkg-config
, kcgi
, fetchFromGitHub
, zlib
, bmake
, libmd
, sqlite
, litterbox
,
}:
let
  kcgiBackport = kcgi.overrideAttrs (oldAttrs: {
    src = fetchFromGitHub {
      owner = "kristapsdz";
      repo = oldAttrs.pname;
      rev = "VERSION_0_13_4";
      hash = "sha256-/j48dlyFwvEVcJuEe4UH9u6HscJu1rXxl2sBdvkPwP8=";
    };

    buildInputs = oldAttrs.buildInputs ++ [ zlib ];
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ bmake ];
  });
in
stdenv.mkDerivation rec {
  pname = "scooper";
  version = "1.3";

  src = fetchurl {
    url = "https://git.causal.agency/scooper/snapshot/scooper-${version}.tar.gz";
    hash = "sha256-j6XdYEcpD7oxnc1p0U5w5e++cMtQJCJHcv1YiMtFe/s=";
  };

  buildInputs = [
    libmd
    kcgiBackport
  ];
  nativeBuildInputs = [ pkg-config ];
  nativeCheckInputs = [ litterbox ];

  strictDeps = true;

  buildFlags = [ "all" ];

  meta = with lib; {
    description = "CGI-based Web interface for the litterbox IRC logger";
    homepage = "https://git.causal.agency/scooper/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "scooper";
    platforms = platforms.unix;
  };
}
