{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "jqfmt";
  version = "unstable-2024-08-15";

  src = fetchFromGitHub {
    owner = "noperator";
    repo = "jqfmt";
    rev = "8fc6f864c295e6bd6b08f36f503b3d809270da61";
    hash = "sha256-tvFp1SJeosJdCHs3c+vceBfacypJc/aFYSj55mBfkB8=";
  };

  vendorHash = "sha256-avpZSgQKFZxLmYGj+2Gi+wSDHnAgF0/hyp4HtoQ0ZCo=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Like gofmt, but for jq";
    homepage = "https://github.com/noperator/jqfmt";
    license = licenses.mit;
    maintainers = with maintainers; [ somasis ];
    mainProgram = "jqfmt";
  };
}
