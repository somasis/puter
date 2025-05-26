{ config
, ...
}:
{
  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];
    zfs = {
      extraPools = [ "${config.networking.fqdnOrHostName}_raid" ];
      forceImportRoot = false;
      devNodes = "/dev/disk/by-id";
    };

    # Restrict the ZFS ARC cache to at most 16GB.
    extraModprobeConfig = ''
      options zfs zfs_arc_max=${toString (1024000000 * 16)}
    '';
  };

  cache.files = [ "/etc/zfs/zpool.cache" ];

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };

    "/boot" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5P2NS0X207175X-part1";
      fsType = "vfat";
    };

    "/nix" = {
      device = "${config.networking.fqdnOrHostName}/nixos/root/nix";
      fsType = "zfs";
    };

    "/persist" = {
      device = "${config.networking.fqdnOrHostName}/nixos/data/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/cache" = {
      device = "${config.networking.fqdnOrHostName}/nixos/root/cache";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/log" = {
      device = "${config.networking.fqdnOrHostName}/nixos/root/log";
      fsType = "zfs";
      neededForBoot = true;
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      pools = [
        "${config.networking.fqdnOrHostName}"
        "${config.networking.fqdnOrHostName}_raid"
      ];

      # Scrub on the first Saturday of each month at 2am.
      interval = "Sat *-*-01..07 02:00:00";
    };

    autoSnapshot = {
      enable = true;

      monthly = 3;
      weekly = 4;

      # The frequent snapshots (every 15 minutes) seem to put
      # a lot of strain on the drives. Disable them.
      frequent = 0;

      # Use UTC for snapshot naming to avoid possible jumps due to timezone changes, DST, etc.
      flags = "-k -p -u";
    };
  };

  programs.fuse.userAllowOther = true;
}
