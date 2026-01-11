{
  lib,
  writeShellApplication,
  coreutils,
  jc,
  jq,
  json2nix,
  nixfmt,

  diffutils,
  writeText,
}:
let
  checkINI = writeText "check.ini" ''
    FirstKeyInGlobalSection=first key
    SecondKeyInGlobalSection=second key
    ThirdKeyInGlobalSectionAlsoANumber=3
    FourthKeyInGlobalSectionAlsoABoolean=true

    [General]
    String = "it's a string"
    HasTwoDuplicateKeys=1
    HasTwoDuplicateKeys=2
    CoerceToTrueBoolean=true
    AlsoCoerceToTrueBoolean=True
    CoerceToFalseBoolean=false
    AlsoCoerceToFalseBoolean=False
  '';

  checkExpectedOutput = writeText "expected.nix" ''
    lib.generators.toINI { } {
      General = {
        AlsoCoerceToFalseBoolean = false;
        AlsoCoerceToTrueBoolean = true;
        CoerceToFalseBoolean = false;
        CoerceToTrueBoolean = true;
        HasTwoDuplicateKeys = 2;
        String = "it's a string";
      };
      globalSection = {
        FirstKeyInGlobalSection = "first key";
        FourthKeyInGlobalSectionAlsoABoolean = true;
        SecondKeyInGlobalSection = "second key";
        ThirdKeyInGlobalSectionAlsoANumber = 3;
      };
    }
  '';
in
writeShellApplication {
  name = "ini2nix";

  runtimeInputs = [
    coreutils
    jc
    json2nix
    jq
    nixfmt
  ];

  checkPhase = ''
    PATH=${
      lib.makeBinPath [
        diffutils
        nixfmt
      ]
    }:$PATH

    NIX_REMOTE=daemon $out/bin/ini2nix ${checkINI} \
        | nixfmt \
        > ./check.nix

    diff -u \
        ./check.nix \
        ${lib.escapeShellArg checkExpectedOutput} \
        || exit $?
  '';

  text = builtins.readFile ../../bin/ini2nix;

  meta = with lib; {
    description = "Convert INI to Nix expressions";
    license = licenses.unlicense;
    maintainers = with maintainers; [ somasis ];
  };
}
