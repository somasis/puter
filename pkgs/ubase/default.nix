{ lib
, stdenv
, fetchgit
,
}:
stdenv.mkDerivation rec {
  pname = "ubase";
  version = "unstable-2024-12-09";

  src = fetchgit {
    url = "git://git.suckless.org/ubase";
    rev = "a570a80ed1606bed43118cb148fc83c3ac22b5c1";
  };

  postPatch = ''
    sed -i \
        -e '1i#include <sys/sysmacros.h>' \
        mountpoint.c stat.c libutil/tty.c
  '';

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "suckless Linux base utils";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
  };
}
