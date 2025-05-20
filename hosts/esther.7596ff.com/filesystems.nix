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

    # "/mnt/raid/cassie" = {
    #   fsType = "zfs";
    #   device = "${config.networking.fqdnOrHostName}_raid/cassie";
    #   options = [ "X-mount.mode=0775" "X-mount.owner=cassie" "X-mount.group=cassie" ];
    # };

    # "/mnt/raid/cassie/timemachine" = {
    #   fsType = "zfs";
    #   device = "${config.networking.fqdnOrHostName}_raid/cassie/timemachine";
    #   options = [ "X-mount.mode=0755" "X-mount.owner=cassie" "X-mount.group=cassie" ];
    # };

    # "/mnt/raid/somasis" = {
    #   fsType = "zfs";
    #   device = "${config.networking.fqdnOrHostName}_raid/somasis";
    #   # options = [ "X-mount.mode=0775" "X-mount.owner=somasis" "X-mount.group=somasis" ];
    # };

    # "/mnt/raid/tv" = {
    #   fsType = "zfs";
    #   device = "${config.networking.fqdnOrHostName}_raid/tv";
    #   options = [ "X-mount.mode=0775" "X-mount.owner=tv" "X-mount.group=tv" ];
    # };

    # "/mnt/portia" = {
    #   device = "cassie@portia.whatbox.ca:/home/cassie/files/music";
    #   fsType = "sshfs";
    #   options = [
    #     "nodev"
    #     "noatime"
    #     "allow_other"
    #     "_netdev"
    #     "x-systemd.automount"
    #     "reconnect"
    #     "dir_cache=yes"
    #     "ServerAliveInterval=15"
    #     "IdentityFile=/home/cassie/.ssh/id_ed25519"
    #   ];
    # };
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
