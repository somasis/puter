{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sol";
  version = "unstable-2024-09-03";

  src = fetchFromGitHub {
    owner = "noperator";
    repo = "sol";
    rev = "7762c5115dd899bfac10d2f46d066de3c0e81774";
    hash = "sha256-0k/LdWWBBxGDtrnkG69lctvPdwie8s3ckICCZ4ERa2M=";
  };

  vendorHash = "sha256-syWp/8JG2ikzvTrin9UfLPf7YEFvz3P0N2QzPDklkWg=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A de-minifier (formatter, exploder, beautifier) for shell one-liners";
    homepage = "https://github.com/noperator/sol";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "sol";
  };
}
