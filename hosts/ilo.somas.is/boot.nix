{
  config,
  pkgs,
  lib,
  ...
}:
{
  console.earlySetup = true;

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 25;

        memtest86.enable = true;
        netbootxyz.enable = true;
      };

      timeout = 0;
    };

    initrd = {
      availableKernelModules = [ "i915" ];

      # NOTE: Necessary for ZFS password prompting via plymouth
      #       <https://github.com/NixOS/nixpkgs/issues/44965>
      systemd = {
        enable = true;

        storePaths = [
          pkgs.busybox
        ] ++ lib.optional config.hardware.bluetooth.enable config.hardware.bluetooth.package;
      };
    };
  };

  services.getty.greetingLine = "o kama pona tawa ${config.networking.fqdnOrHostName}.";

  # FIXME Remove when <https://github.com/NixOS/nixpkgs/issues/369376> is fixed
  # Workaround systemd possibly causing freezes during suspend.
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
}
