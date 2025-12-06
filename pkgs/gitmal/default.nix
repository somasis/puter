{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gitmal";
  version = "1.0.0-unstable-2025-12-02";

  src = fetchFromGitHub {
    owner = "antonmedv";
    repo = "gitmal";
    rev = "v${version}";
    hash = "sha256-laQYZ+7TA/PwtvUfHHGW6i/58iedRW63IzW12j8+9WA=";
  };

  vendorHash = "sha256-LQBG6RPjefq6dFMcSkbRKJTxvHJVYeK9/VQxgYxCDmQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A static page generator for repos";
    homepage = "https://github.com/antonmedv/gitmal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "gitmal";
  };
}
