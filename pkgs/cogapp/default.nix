{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "cogapp";
  version = "3.5.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qei4wx5eR95yLyfquh7BKN1sjntgFVVdnI7apa1gkrQ=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  pythonImportsCheck = [
    "cogapp"
  ];

  meta = {
    description = "Cog: A content generator for executing Python snippets in source files";
    homepage = "https://pypi.org/project/cogapp/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "cogapp";
  };
}
