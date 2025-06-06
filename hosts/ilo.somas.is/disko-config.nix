{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";

        # WD_BLACK SN850 NVMe M.2 2230, 1TB
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
                mountOptions = [
                  "umask=0077"
                  "nofail"
                ];
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
        canmount = "on";
        "com.sun:auto-snapshot" = "false";

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
          options = {
            mountpoint = "none";
            canmount = "off";
            refreservation = "8G";
          };
        };

        "nixos" = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            canmount = "off";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
        };

        "nixos/root/runtime" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.devices = "on";
          postCreateHook = ''
            zfs list -t snapshot -H -o name | grep -E '^ilo\.somas\.is/nixos/root/runtime' \
                || zfs snapshot ilo.somas.is/nixos/root/runtime@blank
          '';
        };

        "nixos/root/cache" = {
          type = "zfs_fs";
          mountpoint = "/cache";
        };

        "nixos/root/log" = {
          type = "zfs_fs";
          mountpoint = "/log";
        };

        "nixos/root/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.atime = "off";
        };

        "nixos/data/persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
          options.canmount = "on";
          options.snapdir = "visible";
          options."com.sun:auto-snapshot" = "true";
        };

        "nixos/data/persist/home/somasis" = {
          type = "zfs_fs";
          mountpoint = "/persist/home/somasis";
          options.canmount = "on";
          options.snapdir = "visible";
          options."com.sun:auto-snapshot" = "true";
        };
      };
    };
  };
}
