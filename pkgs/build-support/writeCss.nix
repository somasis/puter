name: stylelintUserConfig: text:
{
  lib,
  pkgs,
  ...
}:
assert (lib.isString name);
assert (lib.isAttrs stylelintUserConfig);
assert (lib.isString text);
let
  inherit (pkgs)
    writeTextFile
    stylelint
    stylelint-config-standard
    ;

  stylelintConfig =
    if stylelintUserConfig == { } then
      { extends = "stylelint-config-standard"; }
    else
      stylelintUserConfig;
in
writeTextFile {
  inherit name;
  inherit text;

  derivationArgs = {
    nativeCheckInputs = [
      stylelint
      stylelint-config-standard
    ];
    stylelintConfig = lib.generators.toJSON { } stylelintConfig;
    passAsFile = [ "stylelintConfig" ];
  };

  checkPhase = ''
    check() {
        exit_code=0

        stylelint ''${stylelintConfig:+--config "$stylelintConfig"} --formatter unix --stdin-filename "$name" < "$name" || exit_code=$?

        case "$exit_code" in
            78) # invalid config file/config not found <https://stylelint.io/user-guide/cli#exit-codes>
                exit_code=0
                ;;
        esac

        return "$exit_code"
    }
  '';
}
