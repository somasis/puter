{
  lib,
  stdenvNoCC,
  cacert,
  mediafire-dl,
  writeShellScript,

  url,
  name ? "${builtins.baseNameOf url}",
  hash,
  postFetch ? "",
  postUnpack ? "",
  meta ? { },
  ...
}:
assert (
  lib.any (prefix: lib.hasPrefix prefix url) [
    "https://www.mediafire.com/file/"
    "https://mediafire.com/file/"
    "http://www.mediafire.com/file/"
    "http://mediafire.com/file/"
  ]
);
stdenvNoCC.mkDerivation {
  inherit
    name
    url
    hash
    postFetch
    postUnpack
    meta
    ;

  nativeBuildInputs = [
    cacert
    mediafire-dl
  ];

  outputHash = hash;
  outputHashAlgo = if hash != "" then null else "sha256";

  builder = writeShellScript "fetch-mediafire-builder.sh" ''
    source $stdenv/setup

    download="$PWD"/download
    mkdir -p "$download"

    pushd "$download"
    mediafire-dl "$url"
    ls -CFlah
    popd

    mv "$download"/* "$out"
    rmdir "$download"
  '';
}
