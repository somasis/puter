{
  lib,
  stdenvNoCC,
  fetchurl,
  jre_headless,
  makeWrapper,
}:
stdenvNoCC.mkDerivation rec {
  pname = "bandcamp-collection-downloader";
  version = "2021-12-05";

  src = fetchurl {
    url = "https://framagit.org/Ezwen/bandcamp-collection-downloader/-/jobs/1515933/artifacts/raw/build/libs/bandcamp-collection-downloader.jar";
    hash = "sha256-nmnPu+E6KgQpwH66Cli0gbDU4PzQQXEscXPyYYkkJC4=";
  };
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/bandcamp-collection-downloader/
    cp $src $out/share/bandcamp-collection-downloader/bandcamp-collection-downloader.jar
    makeWrapper ${jre_headless}/bin/java $out/bin/bandcamp-collection-downloader \
        --argv0 bandcamp-collection-downloader \
        --add-flags "-jar $out/share/bandcamp-collection-downloader/bandcamp-collection-downloader.jar"
  '';

  meta = with lib; {
    description = "Tool for automatically downloading releases purchased with a Bandcamp account";
    homepage = "https://framagit.org/Ezwen/bandcamp-collection-downloader";
    license = licenses.agpl3Only;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    maintainers = with maintainers; [ somasis ];
    inherit (jre_headless.meta) platforms;
  };
}
