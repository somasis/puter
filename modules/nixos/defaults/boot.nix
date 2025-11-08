{
  config,
  ...
}:
{
  boot = {
    # Allow emergency access if boot fails.
    initrd.systemd.emergencyAccess = true;

    # Allow for avoiding usage of mountpoint=legacy for the root zpool.
    zfs = {
      extraPools = [ config.networking.fqdnOrHostName ];
      devNodes = "/dev/disk/by-id";
    };
  };
}
