{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,

  cogapp,
  pkg-config,
  ncurses,
  zlib,
  bzip2,
  xz,

  cunit,

  groff,

  # TODO man-db is also supported, but I'm not sure how best to support
  #      both mandoc and man-db at the package level without installing
  #      both somehow... this is only the case because I use mandoc on
  #      my system.
  mandoc,
  xdg-utils,
}:

stdenv.mkDerivation rec {
  pname = "qman";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "plp13";
    repo = "qman";
    rev = "v${version}";
    hash = "sha256-pgxRk3XSR+pqPlfL65BTLI3vvGTP0GooT5ovompbx7E=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cogapp
    pkg-config
  ];

  nativeCheckInputs = [
    cunit
  ];

  buildInputs = [
    ncurses
    zlib
    bzip2
    xz
  ];

  runtimeInputs = [
    groff
    mandoc
    xdg-utils
  ];

  # TODO get tests working, I ran into issues with this script
  # not being executable for some reason at build time
  # <https://github.com/plp13/qman/blob/main/src/qman_tests_list.sh>
  doCheck = false;

  mesonFlags = [
    (lib.mesonOption "tests" "disabled")
    (lib.mesonOption "configdir" ''${placeholder "out"}/etc/xdg'')
  ];

  patchPhase = ''
    # Force use of mandoc by default, see TODO
    sed -i \
        -e '/\[misc\]/ a system_type=mandoc' \
        config/qman.conf

    substituteInPlace src/config_def.py \
        --replace-fail /usr/bin/man "${mandoc}/bin/man" \
        --replace-fail /usr/bin/whatis "${mandoc}/bin/whatis" \
        --replace-fail /usr/bin/apropos "${mandoc}/bin/apropos" \
        --replace-fail /usr/bin/groff "${groff}/bin/groff" \
        --replace-fail /usr/bin/xdg-open "${xdg-utils}/bin/xdg-open" \
        --replace-fail /usr/bin/xdg-email "${xdg-utils}/bin/xdg-email"
  '';

  meta = {
    description = "A more modern man page viewer for our terminals";
    homepage = "https://github.com/plp13/qman";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "qman";
    platforms = lib.platforms.all;
  };
}
