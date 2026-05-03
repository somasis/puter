{
  lib,
  config,
  osConfig ? { },
  ...
}:
let
  inherit (lib)
    mkAliasOptionModule
    mkOption
    types
    ;

  inherit (lib.strings)
    normalizePath
    ;

  mkPath =
    default: description:
    mkOption {
      inherit description;
      default = normalizePath "${default}";
      type = types.path;
    };

  module = {
    options.persistence = {
      data = mkPath "/data" ''
        The system's default data directory.
      '';
    };

    imports = [
      (mkAliasOptionModule [ "data" ] [ "home" "persistence" config.persistence.data ])
    ];
  };
in
if osConfig.environment ? persistence then module else { }
