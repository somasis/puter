{
  lib,
  writeShellApplication,
  nix,
  coreutils,
  nixfmt-rfc-style,
}:
writeShellApplication {
  name = "json2nix";

  runtimeInputs = [
    coreutils
    nix
    nixfmt-rfc-style
  ];

  text = builtins.readFile ./json2nix.bash;

  meta = with lib; {
    description = "Convert JSON to Nix expressions";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
