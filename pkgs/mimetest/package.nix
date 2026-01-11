{
  lib,
  file,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "mimetest";
  version = "0.1";

  src = ./.;

  buildInputs = [
    file
    file.dev
  ];

  makeFlags = [
    "prefix="
    "DESTDIR=$(out)"
  ];

  meta = with lib; {
    description = "Test files against MIME types";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
