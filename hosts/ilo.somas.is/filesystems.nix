{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];

    swraid.enable = false;

    zfs = {
      requestEncryptionCredentials = true;
      forceImportRoot = false;
    };

    # Restrict the ZFS ARC cache to 8GB.
    extraModprobeConfig = ''
      options zfs zfs_arc_max=${toString (1024000000 * 8)}
    '';

    # Use Pop_OS! values for swap configuration
    # <https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram>
    kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    initrd.systemd.services.initrd-rollback-root = lib.mkIf config.boot.initrd.systemd.enable {
      description = "Rollback to blank /";

      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import-${config.networking.fqdnOrHostName}.service" ];
      before = [ "sysroot.mount" ];
      path = [ pkgs.zfs ];

      unitConfig.DefaultDependencies = "no";

      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r ${config.fileSystems."/".device}@blank
      '';
    };

    initrd.postResumeCommands = lib.optionalString (
      !config.boot.initrd.systemd.enable
    ) "zfs rollback -r ${config.fileSystems."/".device}@blank";
  };

  fileSystems = {
    "/" = {
      device = "${config.networking.fqdnOrHostName}/runtime";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

    "/boot" = {
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b49267e67-part1";
      fsType = "vfat";
    };

    # Necessary so that files created by Nix under /home are created with
    # the correct permissions by default? TODO
    "/home" = {
      device = "none";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [ "mode=755" ];
    };

    "/nix" = {
      device = "${config.networking.fqdnOrHostName}/nix";
      fsType = "zfs";
      neededForBoot = true;
      options = [
        "x-gvfs-hide"
        "zfsutil"
      ];
    };

    "/data" = {
      device = "${config.networking.fqdnOrHostName}/data";
      fsType = "zfs";
      neededForBoot = true;
      options = [ "zfsutil" ];
    };

    "/mnt/windows" = {
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b49267e67-part5";
      fsType = "ntfs3";
      options = [
        "nofail"
        "windows_names"
        "hide_dot_files"
        "discard"
        "uid=${toString config.users.users.kylie.uid}"
        "gid=${toString config.users.groups.${config.users.users.kylie.group}.gid}"
      ];
    };
  };

  programs.fuse.userAllowOther = true;

  services = {
    zfs = {
      trim.enable = true;

      autoScrub = {
        enable = true;
        pools = [ config.networking.fqdnOrHostName ];

        # Scrub on the first Sunday of each month at 8am.
        interval = "Sun *-*-01..07 08:00:00";
      };

      autoSnapshot = {
        enable = true;
        frequent = 8;
        hourly = 24;
        daily = 7;

        # Anything further than a week out should be fetched from Restic.
        weekly = 0;
        monthly = 0;

        # -k: Keep empty snapshots.
        # -p: Create snapshots in parallel.
        # -u: Use UTC for snapshot naming to avoid possible jumps due to timezone changes, DST, etc.
        flags = "-p -u";
      };
    };

    udisks2.enable = true;
  };

  # Only scrub when on AC power.
  systemd.timers.zfs-scrub.unitConfig.ConditionACPower = true;

  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b49267e67-part2";
      randomEncryption = true;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  environment.systemPackages = with pkgs; [
    httm
    ntfsprogs
  ];
}
