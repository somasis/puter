{ lib
, stdenv
, fetchgit
,
}:
stdenv.mkDerivation rec {
  pname = "sbase";
  version = "unstable-2024-12-09";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "279cec88898c2386430d701847739209fabf6208";
  };

  makeFlags = [ "PREFIX=$out" ];
  buildFlags = [ "sbase-box" ];
  installFlags = [ "sbase-box-install" ];

  postInstall = ''
    rm \
        $out/bin/cksum  $out/share/man/man1/cksum.1 \
        $out/bin/find   $out/share/man/man1/find.1 \
        $out/bin/xargs  $out/share/man/man1/xargs.1 \
        $out/bin/sponge $out/share/man/man1/sponge.1
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "suckless Unix tools";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
  };
}
