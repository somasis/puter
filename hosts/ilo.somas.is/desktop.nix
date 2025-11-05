{
  lib,
  pkgs,
  ...
}:
{
  boot = {
    # Tweak allowed sysrq key actions. For breaking out of a dying system.
    # <https://docs.kernel.org/admin-guide/sysrq.html>
    # kernel.sysrq expects a bitmask, so we can construct one like so.
    kernel.sysctl."kernel.sysrq" = lib.foldl' (x: y: x + y) 0 [
      4 # enable keyboard controls
      16 # enable filesystem syncing
      32 # enable remounting filesystems read-only
      64 # enable signalling processes
      128 # enable reboot/poweroff
      256 # enable renicing all realtime tasks
    ];

    # consoleLogLevel = 3;
    # initrd.verbose = false;
    # kernelParams = [
    #   # "quiet"
    #   # "splash"
    #   "boot.shell_on_fail"
    #   # "udev.log_priority=3"
    #   "rd.systemd.show_status=auto"
    # ];

    # Provide a nice splash screen. (<Esc> will show boot log anyway)
    # plymouth = {
    #   enable = true;
    #   themePackages = with pkgs; [ nixos-bgrt-plymouth ];
    #   theme = "nixos-bgrt";

    #   extraConfig = "DeviceScale=1";
    #   font = "${pkgs.inter}/share/fonts/truetype/Inter.ttc";
    # };

    # <https://wiki.archlinux.org/title/Docker#Enable_native_overlay_diff_engine>
    extraModprobeConfig = ''
      options overlay metacopy=off redirect_dir=off
    '';
  };

  services = {
    # Use dbus-broker since it's faster.
    dbus.implementation = "broker";

    journald.extraConfig = lib.generators.toKeyValue { } {
      MaxRetentionSec = "3month";
    };

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = true;
    };

    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "wheel" ];

      # Enable usbguard-notifier usage.
      dbus.enable = true;

      # Automatically allow devices.
      # We will block devices inserted while on the lock screen.
      implicitPolicyTarget = "allow";
    };
  };

  programs = {
    bash = {
      completion.enable = true;
      enableLsColors = false;
    };

    kdeconnect.enable = true;
    kde-pim.enable = true; # TODO testing
    partition-manager.enable = true;

    captive-browser = {
      enable = true;
      browser = ''
        qutebrowser \
            --target private-window --override-restore \
            --set 'content.proxy' "$PROXY" "$@"
      '';
      interface = "wlp166s0";
    };
  };

  cache.directories = [
    {
      directory = "/var/lib/usbguard";
      mode = "0775";
      user = "root";
      group = "wheel";
    }
  ];

  systemd = {
    packages = with pkgs; [ usbguard-notifier ];
    user.services.usbguard-notifier = {
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
    };
    # // lib.mkIf config.services.systemd-lock-handler.enable {
    #   targets.lock.conflicts = [ "usbguard-notifier.service" ];
    #   targets.unlock.conflicts = [ "usbguard-block.service" ];

    #   services.usbguard-block = {
    #     description = "Arm USBGuard to block any newly-connected devices";
    #     conflicts = [ "unlock.target" ];
    #     wantedBy = [ "lock.target" "sleep.target" ];

    #     serviceConfig = {
    #       Type = "oneshot";
    #       ExecStart = [
    #         "${config.services.usbguard.package}/bin/usbguard set-parameter InsertedDevicePolicy block"
    #         "${config.services.usbguard.package}/bin/usbguard set-parameter ImplicitPolicyTarget block"
    #       ];

    #       RemainAfterExit = true;

    #       ExecStop = [
    #         "${config.services.usbguard.package}/bin/usbguard set-parameter InsertedDevicePolicy ${config.services.usbguard.insertedDevicePolicy}"
    #         "${config.services.usbguard.package}/bin/usbguard set-parameter ImplicitPolicyTarget ${config.services.usbguard.implicitPolicyTarget}"
    #       ];
    #     };
    #   };
    # };
  };

  environment.systemPackages = with pkgs; [
    waypipe
    usbguard-notifier
  ];

  virtualisation = {
    containers.enable = true;

    podman = {
      enable = true;

      defaultNetwork.settings.dns_enabled = true;

      dockerSocket.enable = true;
      dockerCompat = true;

      autoPrune.enable = true;
    };
  };

  environment.plasma6.excludePackages =
    with pkgs;
    with kdePackages;
    [
      kate
    ];
}
