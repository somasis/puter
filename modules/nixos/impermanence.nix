{
  sources,

  lib,
  config,
  ...
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
    sync = mkPath "/persist/sync" ''
      The system's default synchronized persist directory. It is able to be shared
      between synchronized machines with, say, Syncthing (services.syncthing).
    '';
  };

  imports = [
    "${sources.impermanence}/nixos.nix"

    # Actually create the aliases options.
    (mkAliasOptionModule [ "persist" ] [ "environment" "persistence" config.persistence.persist ])
    (mkAliasOptionModule [ "cache" ] [ "environment" "persistence" config.persistence.cache ])
    (mkAliasOptionModule [ "sync" ] [ "environment" "persistence" config.persistence.sync ])
  ];

  config = {
    environment.persistence = {
      persist.persistentStoragePath = config.persistence.persist;
      cache.persistentStoragePath = config.persistence.cache;
      log.persistentStoragePath = config.persistence.log;
      sync.persistentStoragePath = config.persistence.sync;

      # Add entries for every user's home directory (and make them owner of it)
      # persist.directories = homes;
      # cache.directories = homes;
      # log.directories = homes;
    };

    cache.directories =
      (lib.optional config.services.fwupd.enable "/var/cache/fwupd")
      ++ (lib.optional config.services.self-deploy.enable "/var/lib/nixos-self-deploy")
      ++ (
        # For every Restic backup job that exists, persist its cache directory.
        let
          jobs = config.services.restic.backups;
          jobNames = builtins.attrNames jobs;
        in
        lib.optionals (jobs != [ ]) (
          map (jobName: {
            directory = "/var/cache/restic-backups-${jobName}";

            # NOTE one of these would be better, but it causes infrec
            # directory = config.systemd.services."restic-backups-${jobName}".environment.RESTIC_CACHE_DIR;
            # directory = "/var/cache/${
            #   config.systemd.services."restic-backups-${jobName}".serviceConfig.CacheDirectory
            # }";
            mode = "0770";
          }) jobNames
        )
      );

    persist = {
      users.root = {
        home = "/root";
        directories = [
          ".cache"
          ".config"
          ".local"
          ".ssh"
        ];
        files = [
          ".bash_history"
        ];
      };

      directories = [
        "/var/log/lastlog"

        # Used for keeping declared users' UIDs and GIDs consistent across boots.
        {
          directory = "/var/lib/nixos";
          user = "root";
          group = "root";
          mode = "0755";
        }
      ]
      ++ (lib.optional config.services.age-keygen.enable "/etc/age")
      ++ (lib.optional config.services.uptimed.enable "/var/lib/uptimed")
      ++ (lib.optional config.services.fwupd.enable "/var/lib/fwupd")
      ++ (lib.optional config.services.accounts-daemon.enable {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      });

      # Persist all host keys (NixOS has default host key locations!)
      files = lib.flatten (
        map (key: [
          key.path
          "${key.path}.pub"
        ]) config.services.openssh.hostKeys
      );
    };
  };
}
