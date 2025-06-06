{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage {
  pname = "stylelint-config-standard";
  version = "36.0.1";

  src = fetchFromGitHub {
    owner = "stylelint";
    repo = "stylelint-config-standard";
    rev = version;
    hash = "sha256-fbDf/q342eTrV0x7bng+w0uuihzkCIbieielT6Ufkzs=";
  };

  npmDepsHash = "sha256-uV8FltfZEu15PCybcv6sAKgYoNt7bElHcsdYUCGbgao=";

  meta = with lib; {
    description = "The standard shareable config for Stylelint";
    homepage = "https://www.npmjs.com/package/stylelint-config-standard";
    license = licenses.mit;
    maintainers = [ maintainers.somasis ];
  };
}
