{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pass,
  # rapidjson,
  # nanoid-cpp,
  sdbus-cpp,
}:

stdenv.mkDerivation {
  pname = "pass-secrets";
  version = "unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "nullobsi";
    repo = "pass-secrets";
    rev = "72dde8b51c10728fc19c646700bb0b1c0ad8c366";
    hash = "sha256-QP4vBNaFsLCL45Mog1A9438rCqnWgnWmRgVuL35S+4U=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    # rapidjson # vendored
    # TODO nanoid-cpp # vendored, but it seems to be difficult to unvendor
    sdbus-cpp
  ];

  runtimeInputs = [
    pass
  ];

  # TODO Un-vendoring nanoid-cpp could be done a lot better.
  # Tried using `cmake/FindNanoid.cmake` from Nanoid's upstream
  # but it didn't seem to work right...
  # patchPhase = ''
  #   rm -r nanoid_cpp
  #   ln -s ${nanoid-cpp.src} nanoid_cpp
  # '';

  cmakeFlags = [
    (lib.cmakeBool "Nanoid_BUILD_TESTS" false)
  ];

  meta = {
    description = "Use pass to store your application secrets";
    homepage = "https://github.com/nullobsi/pass-secrets";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "pass-secrets";
    platforms = lib.platforms.all;
  };
}
