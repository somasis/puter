{
  lib,
  writeShellApplication,
  coreutils,
  nix,
  nixfmt,

  diffutils,
  jq,
  writeText,
}:
let
  checkInput = writeText "check.json" ''
    {
      "object": {
        "array": [
          "item1",
          "item2"
        ],
        "boolean": true,
        "float": 1.125,
        "number": 1,
        "string": "it's a string"
      }
    }
  '';

  checkExpectedOutput = writeText "check.nix" ''
    {
      object = {
        array = [
          "item1"
          "item2"
        ];
        boolean = true;
        float = 1.125;
        number = 1;
        string = "it's a string";
      };
    }
  '';
in
writeShellApplication {
  name = "json2nix";

  runtimeInputs = [
    coreutils
    nix
    nixfmt
  ];

  text = builtins.readFile ../../bin/json2nix;

  checkPhase = ''
    PATH=${
      lib.makeBinPath [
        diffutils
        nixfmt
      ]
    }:$PATH

    NIX_REMOTE=daemon $out/bin/json2nix ${checkInput} \
        | nixfmt \
        > ./check.nix

    diff -u \
        ./check.nix \
        ${lib.escapeShellArg checkExpectedOutput} \
        || exit $?
  '';

  meta = with lib; {
    description = "Convert JSON to Nix expressions";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
