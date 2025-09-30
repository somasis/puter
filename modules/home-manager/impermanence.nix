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
      persist = mkPath "/persist/${config.home.homeDirectory}" ''
        The system's default persist directory.
        This directory is used for more permanent data, such as what would go in
        $XDG_DATA_HOME, $XDG_STATE_HOME, or $XDG_CONFIG_HOME.
      '';
      cache = mkPath "/cache/${config.home.homeDirectory}" ''
        The system's default cache directory.
        This directory is used for less permanent data, such as what would go in
        $XDG_CACHE_HOME.
      '';
      sync = mkPath "/persist/sync/${config.home.homeDirectory}" ''
        The system's default synchronized persist directory.
        This directory is used for more permanent data, such as what would go in
        $XDG_DATA_HOME, $XDG_STATE_HOME, or $XDG_CONFIG_HOME; it is able to be
        shared between synchronized machines.
      '';
    };

    imports = [
      (mkAliasOptionModule [ "persist" ] [ "home" "persistence" config.persistence.persist ])
      (mkAliasOptionModule [ "cache" ] [ "home" "persistence" config.persistence.cache ])
      (mkAliasOptionModule [ "sync" ] [ "home" "persistence" config.persistence.sync ])
    ];
  };
in
if osConfig.environment ? persistence then module else { }
