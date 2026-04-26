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
  };

  imports = [
    "${sources.impermanence}/nixos.nix"

    # Actually create the aliases options.
    (mkAliasOptionModule [ "persist" ] [ "environment" "persistence" config.persistence.persist ])
    (mkAliasOptionModule [ "cache" ] [ "environment" "persistence" config.persistence.cache ])
  ];

  config = {
    environment.persistence = {
      persist.persistentStoragePath = config.persistence.persist;
      cache.persistentStoragePath = config.persistence.cache;
    };

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
      ++ (lib.optional (config.boot ? "lanzaboote" && config.boot.lanzaboote.enable) {
        directory = config.boot.lanzaboote.pkiBundle;
      })
      ++ (lib.optional config.services.age-keygen.enable "/etc/age")
      ++ (lib.optional config.services.uptimed.enable {
        directory = "/var/lib/uptimed";
        user = "uptimed";
        group = "uptimed";
      })
      ++ (lib.optional config.services.fwupd.enable {
        directory = "/var/lib/fwupd";
        user = "fwupd-refresh";
        group = "fwupd-refresh";
      })
      ++ (lib.optional config.services.accounts-daemon.enable {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      })
      ++ (lib.optional config.services.fprintd.enable "/var/lib/fprint")
      ++ (lib.optional config.services.upower.enable "/var/lib/upower")
      ++ (lib.optional config.services.bluetooth.enable {
        mode = "0700";
        directory = "/var/lib/bluetooth";
      })
      ++ (lib.optional config.networking.networkmanager.enable {
        directory = "/etc/NetworkManager/system-connections";
        mode = "0700";
      })
      ++ (lib.optionals config.services.printing.enable [
        {
          mode = "0755";
          directory = "/var/lib/cups";
        }
        {
          mode = "0755";
          user = "root";
          group = "lp";
          directory = "/var/log/cups";
        }
      ]);

      # Persist all host keys (NixOS has default host key locations!)
      files = lib.flatten (
        map (key: [
          key.path
          "${key.path}.pub"
        ]) config.services.openssh.hostKeys
      );
    };

    cache.directories =
      (lib.optionals config.services.fwupd.enable [
        "/var/cache/fwupd"
        {
          directory = "/var/cache/fwupdmgr";
          user = "fwupd-refresh";
          group = "fwupd-refresh";
        }
      ])
      ++ (lib.optional config.services.geoclue2.enable {
        directory = "/var/lib/geoclue";
        user = "geoclue";
        group = "geoclue";
      })
      ++ (lib.optional config.services.usbguard.enable {
        directory = "/var/lib/usbguard";
        mode = "0775";
        user = "root";
        group = "wheel";
      })
      # Enable ALSA and preserve the mixer state across boots.
      ++ (lib.optional config.hardware.alsa.enablePersistence "/var/lib/alsa")
      ++ (lib.optional config.services.self-deploy.enable "/var/lib/nixos-self-deploy")
      ++ (lib.optional config.networking.networkmanager.enable "/var/lib/NetworkManager")
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
      )
      ++ (lib.optionals config.services.printing.enable [
        {
          mode = "0770";
          user = "root";
          group = "lp";
          directory = "/var/cache/cups";
        }
        {
          mode = "0710";
          user = "root";
          group = "lp";
          directory = "/var/spool/cups";
        }
      ])
      ++ (lib.optional config.powerManagement.powertop.enable "/var/cache/powertop");
  };
}
