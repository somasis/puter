{
  lib,
  stdenv,
  fetchFromGitHub,
  libdiscid,
  glib,
  libmirage,
  autoreconfHook,
  pkg-config,
}:
stdenv.mkDerivation rec {
  pname = "image-id";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "kepstin";
    repo = "image-id";
    rev = "v${version}";
    hash = "sha256-NYgZvSyGJS/hwhIGbUbexFKaXrN+kO6u6yjIWEvMwj8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libdiscid
    libmirage
    glib # required by libmirage
  ];

  CFLAGS = "-I${libmirage}/include/libmirage-3.2";

  meta = {
    description = "Generate MusicBrainz Disc IDs from images of music CDs";
    homepage = "https://github.com/kepstin/image-id";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "image-id";
    platforms = lib.platforms.all;
  };
}
