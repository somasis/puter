{ lib
, rustPlatform
, fetchFromGitHub
,
}:

rustPlatform.buildRustPackage rec {
  pname = "hledger-fmt";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "hledger-fmt";
    rev = "v${version}";
    hash = "sha256-ZZUEJzceBTt4ObiEJU1WUC0Ic+LijiyAeeVVhxUp7vw=";
  };

  cargoHash = "sha256-k/QbquQHmfvnyLgQO10J5XiRX5pHJ85tVm4zF31zzjs=";

  meta = {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "hledger-fmt";
  };
}
