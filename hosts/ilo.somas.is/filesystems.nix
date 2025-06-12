{
  config,
  lib,
  # disko,
  ...
}:
{
  # imports = [
  #   disko.nixosModules.disko
  #   ./disko-config.nix
  # ];

  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];

    swraid.enable = false;

    # Fix there not being enough space for some Nix builds
    tmp.useTmpfs = true;

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

    initrd.systemd.services.initrd-rollback-root = lib.mkIf (config.boot.initrd.systemd.enable) {
      after = [ "zfs-import-rpool.service" ];
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      path = [ config.boot.zfs.package.userspaceTools ];
      description = "Rollback to blank /";
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r ${config.networking.fqdnOrHostName}/nixos/root/runtime@blank
      '';
    };

    initrd.postResumeCommands = lib.optionalString (
      !config.boot.initrd.systemd.enable
    ) "zfs rollback -r ${config.networking.fqdnOrHostName}/nixos/root/runtime@blank";
  };

  fileSystems = {
    "/" = {
      device = "${config.networking.fqdnOrHostName}/nixos/root/runtime";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_2045A0800564-part1";
      fsType = "vfat";
    };

    "/home" = {
      device = "none";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "mode=755"
        # NOTE: Limit /home to 512mb of memory. I don't want to accidentally lock up
        #       the machine by extracting stuff to /home.
        # "size=512m"
      ];
    };

    "/nix" = {
      device = "${config.networking.fqdnOrHostName}/nixos/root/nix";
      fsType = "zfs";
      neededForBoot = true;
      options = [ "x-gvfs-hide" ];
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

    "/persist" = {
      device = "${config.networking.fqdnOrHostName}/nixos/data/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist/home/somasis" = {
      device = "${config.networking.fqdnOrHostName}/nixos/data/persist/home/somasis";
      fsType = "zfs";
    };
  };

  swapDevices = [
    { label = "disk-ssd-swap"; }
  ];

  boot.zfs.allowHibernation = true;

  cache = {
    # <https://nixos.org/manual/nixos/unstable/#sec-zfs-state>
    files = [ "/etc/zfs/zpool.cache" ];
    directories = [ "/var/lib/udisks2" ];
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
        monthly = 3;
        weekly = 4;

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

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };
}
