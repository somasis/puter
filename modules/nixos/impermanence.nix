{ lib
, config
, ...
}:
let
  inherit (lib)
    mkAliasOptionModule
    mkOption
    types
    ;

  mkPath =
    default: description:
    mkOption {
      inherit default description;
      type = types.path;
    };
in
{
  options.persistence = {
    persist = mkPath "/persist" ''
      The system's default persist directory.
      This directory is used for more permanent data, such as what would go in
      /etc, /var/db, or /var/lib.
    '';
    cache = mkPath "/cache" ''
      The system's default cache directory.
      This directory is used for less permanent data, such as what would go in
      /var/cache.
    '';
    log = mkPath "/log" ''
      The system's default log directory.
      This directory is used for somewhat permanent data, such as what would go in
      /var/log, or /var/spool.
    '';
    sync = mkPath "/persist/sync" ''
      The system's default synchronized persist directory. It is able to be shared
      between synchronized machines with, say, Syncthing (services.syncthing).
    '';
  };

  # Actually create the aliases options.
  imports = [
    (mkAliasOptionModule [ "persist" ] [ "environment" "persistence" config.persistence.persist ])
    (mkAliasOptionModule [ "cache" ] [ "environment" "persistence" config.persistence.cache ])
    (mkAliasOptionModule [ "log" ] [ "environment" "persistence" config.persistence.log ])
    (mkAliasOptionModule [ "sync" ] [ "environment" "persistence" config.persistence.sync ])
  ];

  config.environment.persistence = {
    persist.persistentStoragePath = config.persistence.persist;
    cache.persistentStoragePath = config.persistence.cache;
    log.persistentStoragePath = config.persistence.log;
    sync.persistentStoragePath = config.persistence.sync;

    # Add entries for every user's home directory (and make them owner of it)
    # persist.directories = homes;
    # cache.directories = homes;
    # log.directories = homes;
  };
}
