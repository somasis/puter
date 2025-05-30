{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_2045A0800564";

        content = {
          type = "gpt";

          partitions = {
            efi = {
              type = "EF00"; # EFI system partition
              size = "1G";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" "nofail" ];
              };
            };

            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "ilo.somas.is";
              };
            };

            swap = {
              size = "32G";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true;
              };
            };
          };
        };
      };
    };

    zpool."ilo.somas.is" = {
      type = "zpool";

      options = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        mountpoint = "none";
        canmount = "off";
        "com.sun:auto-snapshot" = "true";

        compression = "zstd";
        dedup = "off";

        dnodesize = "legacy";

        devices = "off";
        relatime = "on";
        acltype = "posix";
        xattr = "sa"; # highly recommended for use with acltype=posix
      };

      datasets = {
        "reserved" = {
          type = "zfs_fs";
          options.refreservation = "8G";
          options.mountpoint = "none";
        };

        "nixos" = {
          type = "zfs_fs";
          options.encryption = "aes-256-gcm";
          options.keyformat = "passphrase";
          options.keylocation = "prompt";
        };

        "nixos/root/cache" = {
          type = "zfs_fs";
          options.mountpoint = "/cache";
        };

        "nixos/root/log" = {
          type = "zfs_fs";
          options.mountpoint = "/log";
        };

        "nixos/root/nix" = {
          type = "zfs_fs";
          options.canmount = "on";
          options.mountpoint = "/nix";
          options.atime = "off";
        };

        "nixos/data/persist" = {
          type = "zfs_fs";
          options.mountpoint = "/persist";
          options.canmount = "on";
          options.snapdir = "visible";
        };

        "nixos/data/persist/home/somasis" = {
          type = "zfs_fs";
          options.mountpoint = "/persist/home/somasis";
          options.canmount = "on";
          options.snapdir = "visible";
        };
      };
    };
  };
}

