{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, dbus
, openssl
, stdenv
, darwin ? null
,
}:

rustPlatform.buildRustPackage rec {
  pname = "aw-watcher-media-player";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "2e3s";
    repo = "aw-watcher-media-player";
    rev = "v${version}";
    hash = "sha256-6lVW2hd1nrPEV3uRJbG4ySWDVuFUi/JSZ1HYJFz0KdQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "aw-client-rust-0.1.0" = "sha256-fCjVfmjrwMSa8MFgnC8n5jPzdaqSmNNdMRaYHNbs8Bo=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      dbus
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
    ];

  meta = with lib; {
    description = "Watcher of system's currently playing media for ActivityWatch";
    homepage = "https://github.com/2e3s/aw-watcher-media-player";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "aw-watcher-media-player";
  };
}
