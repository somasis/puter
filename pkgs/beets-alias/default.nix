{
  lib,
  python3,
  beets,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "beets-alias";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kergoth";
    repo = "beets-alias";
    rev = "v${version}";
    hash = "sha256-dCfMr9sWHCIr8LXgbymoDCV1WaWW++OxsMpUm7xdAQ4=";
  };

  build-system = with python3.pkgs; [ poetry-core ];

  nativeBuildInputs = [ beets ];

  meta = {
    description = "Beets plugin that lets you define command aliases, much like git";
    homepage = "https://github.com/kergoth/beets-alias";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
  };
}
