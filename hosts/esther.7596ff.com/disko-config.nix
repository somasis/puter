{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";

        # Samsung 980 Pro 1TB M.2-2280 PCIe 4.0 NVMe solid state drive
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NS0X207175X";

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
                pool = "esther.7596ff.com";
              };
            };
          };
        };
      };

      # Prepare a ZFS-managed RAID. Check out the topology declared in
      # `zpool.datasets."esther.7596ff.com_raid".mode.topology` to see
      # how the raidz1 is constructed from /dev/disk/by-path.
      raid = {
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "esther.7596ff.com_raid";
              };
            };
          };
        };
      };
    };

    zpool = {
      "esther.7596ff.com" = {
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
            };
          };

          "nixos/root/runtime" = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = ''
              zfs list -t snapshot -H -o name | grep -E '^esther\.7596ff\.com/nixos/root/runtime' \
                  || zfs snapshot esther.7596ff.com/nixos/root/runtime@blank
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
            options = {
              snapdir = "visible";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };

      "esther.7596ff.com_raid" = {
        type = "zpool";

        mode.topology = {
          type = "topology";
          vdev = [
            {
              mode = "raidz1";
              members = [
                # Use /dev/disk/by-path, in hopes that autoreplace=on will work simply by
                # swapping out one of the drives on the hard drive rack.
                "/dev/disk/by-path/pci-0000:02:00.1-ata-4.0"
                "/dev/disk/by-path/pci-0000:02:00.1-ata-3.0"
                "/dev/disk/by-path/pci-0000:02:00.1-ata-1.0"
                "/dev/disk/by-path/pci-0000:02:00.1-ata-2.0"
              ];
            }
          ];
        };

        options = {
          ashift = "12";

          # Allow for drives to be replaced easily; ideally, if any of those drives in
          # /dev/disk/by-path/pci-000:02:00.1-ata-... get swapped out with a new one,
          # ZFS should just be able to automatically initiate drive replacing once it
          # sees that the drive is completely different.
          autoreplace = "on";
        };

        rootFsOptions = {
          mountpoint = "/mnt/raid";

          compression = "zstd";
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
              refreservation = "32G";
            };
          };

          "cassie" = {
            type = "zfs_fs";
            mountpoint = "/mnt/raid/cassie";
            options."com.sun:auto-snapshot" = "true";
          };

          "cassie/timemachine" = {
            type = "zfs_fs";
            mountpoint = "/mnt/raid/cassie/timemachine";
            options."com.sun:auto-snapshot" = "false";
            options.quota = "500G";
          };

          "somasis" = {
            type = "zfs_fs";
            mountpoint = "/mnt/raid/somasis";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
