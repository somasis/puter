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
    data = mkPath "/data" ''
      The system's default data directory.
    '';
  };

  imports = [
    "${sources.impermanence}/nixos.nix"

    # Actually create the aliases option.
    (mkAliasOptionModule [ "data" ] [ "environment" "persistence" config.persistence.data ])
  ];

  config = {
    environment.persistence.data.persistentStoragePath = config.persistence.data;

    data = with lib; {
      users.root = {
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
        # Used for keeping declared users' UIDs and GIDs consistent across boots.
        {
          directory = "/var/lib/nixos";
          user = "root";
          group = "root";
          mode = "0755";
        }
      ]
      ++ (optional (config.boot ? "lanzaboote" && config.boot.lanzaboote.enable) {
        directory = config.boot.lanzaboote.pkiBundle;
      })
      ++ (optional config.services.age-keygen.enable "/etc/age")
      ++ (optional config.services.uptimed.enable {
        directory = "/var/lib/uptimed";
        user = "uptimed";
        group = "uptimed";
      })
      ++ (optionals config.services.fwupd.enable [
        "/var/cache/fwupd"
        {
          directory = "/var/lib/fwupd";
          user = "fwupd-refresh";
          group = "fwupd-refresh";
        }
        {
          directory = "/var/cache/fwupdmgr";
          user = "fwupd-refresh";
          group = "fwupd-refresh";
        }
      ])
      ++ (optional config.services.accounts-daemon.enable {
        directory = "/var/lib/AccountsService";
        mode = "0775";
      })
      ++ (optional config.services.fprintd.enable "/var/lib/fprint")
      ++ (optional config.services.upower.enable "/var/lib/upower")
      ++ (optional config.hardware.bluetooth.enable {
        mode = "0700";
        directory = "/var/lib/bluetooth";
      })
      ++ (optional config.networking.networkmanager.enable {
        directory = "/etc/NetworkManager/system-connections";
        mode = "0700";
      })
      ++ (optionals config.services.printing.enable [
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
      ++ (optional config.services.geoclue2.enable {
        directory = "/var/lib/geoclue";
        user = "geoclue";
        group = "geoclue";
      })
      ++ (optional config.services.usbguard.enable {
        directory = "/var/lib/usbguard";
        mode = "0775";
        user = "root";
        group = "wheel";
      })
      # Enable ALSA and preserve the mixer state across boots.
      ++ (optional config.hardware.alsa.enablePersistence "/var/lib/alsa")
      ++ (optional config.services.udisks2.enable "/var/lib/udisks2")
      ++ (optional config.services.self-deploy.enable "/var/lib/nixos-self-deploy")
      ++ (optional config.networking.networkmanager.enable "/var/lib/NetworkManager")
      ++ (
        # For every Restic backup job that exists, persist its cache directory.
        let
          jobs = config.services.restic.backups;
          jobNames = builtins.attrNames jobs;
        in
        optionals (jobs != [ ]) (
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
      ++ (optional config.powerManagement.powertop.enable "/var/cache/powertop");

      # Persist all host keys (NixOS has default host key locations!)
      files = flatten (
        map (key: [
          key.path
          "${key.path}.pub"
        ]) config.services.openssh.hostKeys
      );
    };
  };
}
