{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "nanoid-cpp";
  version = "unstable-2024-02-19";

  src = fetchFromGitHub {
    owner = "mcmikecreations";
    repo = "nanoid_cpp";
    rev = "9105e0f3887d518162124e09c3d27612b853733d";
    hash = "sha256-wHJFb7yfOhDaUizASYJoAceMwYCBe53m4VJnDF6vURU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "A tiny, URL-friendly, unique string ID generator for C++, implementation of ai's nanoid";
    homepage = "https://github.com/mcmikecreations/nanoid_cpp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "nanoid-cpp";
    platforms = lib.platforms.all;
  };
}
