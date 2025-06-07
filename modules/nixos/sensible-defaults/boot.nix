{ config, ... }:
{
  # Allow for avoiding usage of mountpoint=legacy for the root zpool.
  boot.zfs = {
    extraPools = [ config.networking.fqdnOrHostName ];
    devNodes = "/dev/disk/by-path";
  };

  # Required for ensuring that impermanence is happy; disko does not
  # currently set neededForBoot in its filesystem configs.
  fileSystems = {
    "/cache".neededForBoot = lib.mkDefault true;
    "/log".neededForBoot = lib.mkDefault true;
    "/persist".neededForBoot = lib.mkDefault true;
  };

  # HACK Required for booting to work with disko's configuration!
  # See <https://github.com/nix-community/disko/issues/312#issuecomment-1666187472>.
  boot.initrd.systemd.services.rollback = {
    description = "Rollback ZFS datasets to a pristine state";
    serviceConfig.Type = "oneshot";
    unitConfig.DefaultDependencies = "no";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-${config.networking.fqdnOrHostName}.service" ];
    before = [ "sysroot.mount" ];
    path = with pkgs; [
      zfs
    ];
    script = ''
      set -ex
      zfs rollback -r ${config.networking.fqdnOrHostName}/nixos/root/runtime@blank && echo "rollback complete"
    '';
  };
}
