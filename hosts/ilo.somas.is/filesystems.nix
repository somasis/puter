{ config
, pkgs
, disko
, ...
}:
{
  imports = [
    disko.nixosModules.disko
    ./disko-config.nix
  ];

  services.udisks2.enable = true;

  boot = {
    supportedFilesystems = [
      "vfat"
      "zfs"
    ];

    swraid.enable = false;

    # Fix there not being enough space for some Nix builds
    tmp.useTmpfs = true;

    zfs.requestEncryptionCredentials = true;
    zfs.extraPools = [ config.networking.fqdnOrHostName ];

    # Restrict the ZFS ARC cache to 8GB.
    extraModprobeConfig = ''
      options zfs zfs_arc_max=${toString (1024000000 * 8)}
    '';
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=755" ];
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

  cache = {
    # <https://nixos.org/manual/nixos/unstable/#sec-zfs-state>
    files = [ "/etc/zfs/zpool.cache" ];
    directories = [ "/var/lib/udisks2" ];
  };

  programs.fuse.userAllowOther = true;

  services.zfs = {
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

  # Only scrub when on AC power.
  systemd.timers.zfs-scrub.unitConfig.ConditionACPower = true;

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };

  # Use Pop_OS! values for swap configuration
  # <https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram>
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
