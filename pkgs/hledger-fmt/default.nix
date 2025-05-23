{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "hledger-fmt";
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "hledger-fmt";
    rev = "v${version}";
    hash = "sha256-BHPg2dgV9aRUQKh6rpaUGHuWGWk1KfEqpqMwC8UfBEs=";
  };

  cargoHash = "sha256-yv8qaFlUmixtiJGlKqmzTVv5WHV+GvTwPI0Naihioco=";

  doCheck = false;

  meta = with lib; {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "hledger-fmt";
  };
}
