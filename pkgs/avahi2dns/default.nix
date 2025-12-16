{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "avahi2dns";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "LouisBrunner";
    repo = "avahi2dns";
    rev = version;
    hash = "sha256-/ugdPLhWa76/rtFRWr4pHhmuvYxIB0sbNnw4m6vnNSg=";
  };

  vendorHash = "sha256-rROxPRFsQC852leigEqfhyoL+e2metSmLNR98WJBEfw=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Small DNS server which interface with avahi (perfect for Alpine Linux and musl";
    homepage = "https://github.com/LouisBrunner/avahi2dns";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "avahi2dns";
  };
}
