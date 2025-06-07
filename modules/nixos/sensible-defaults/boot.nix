{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Allow for avoiding usage of mountpoint=legacy for the root zpool.
  boot.zfs = {
    extraPools = [ config.networking.fqdnOrHostName ];
    devNodes = "/dev/disk/by-id";
  };
}
