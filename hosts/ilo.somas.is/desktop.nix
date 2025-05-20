{ config
, lib
, pkgs
, ...
}:
{
  # Use dbus-broker since it's faster.
  services.dbus.implementation = "broker";

  # services.xserver.enable = true;

  # services = {
  #   xserver = {
  #     enable = true;
  #     tty = 1;

  #     displayManager.startx.enable = true;
  #   };

  #   greetd = {
  #     enable = true;
  #     package = pkgs.greetd.tuigreet;
  #     restart = false;

  #     vt = 1;

  #     settings =
  #       # Log startx to systemd journal.
  #       let
  #         startx =
  #           pkgs.writeShellScript "startx" ''
  #             exec \
  #                 ${config.systemd.package}/bin/systemd-cat \
  #                     --identifier=startx \
  #                     --stderr-priority=err \
  #                     ${pkgs.xorg.xinit}/bin/startx "$@" -- \
  #                         -keeptty \
  #                         -logfile >(
  #                             ${pkgs.gnused}/bin/sed -E 's/^\[ +[0-9]+\.[0-9]+\] //' \
  #                                 | ${config.systemd.package}/bin/systemd-cat -t Xorg --level-prefix=false
  #                         ) \
  #                         -logverbose 7 \
  #                         -verbose 0
  #           '';
  #       in
  #       rec
  #       {
  #         initial_session = {
  #           user = builtins.head (builtins.attrNames (
  #             lib.filterAttrs (_: v: v.isNormalUser) config.users.users
  #           ));

  #           command = startx;
  #         };

  #         default_session.command = ''
  #           ${pkgs.greetd.tuigreet}/bin/tuigreet -c ${initial_session.command}
  #         '';
  #       };
  #   };
  # };

  # Force is required because services.xserver forces xdg.*.enable to true.
  # xdg.autostart.enable = lib.mkForce false;
  # xdg.menus.enable = lib.mkForce true;
  # xdg.mime.enable = lib.mkForce true; # TODO
  # xdg.sounds.enable = lib.mkForce false;

  services.journald.extraConfig = lib.generators.toKeyValue { } {
    MaxRetentionSec = "3month";
  };

  programs.bash = {
    completion.enable = true;
    enableLsColors = false;
  };

  # services.gvfs.enable = true;
  # services.tumbler.enable = true;
  # programs.dconf.enable = true;

  # Tweak allowed sysrq key actions. For breaking out of a dying system.
  # <https://docs.kernel.org/admin-guide/sysrq.html>
  boot.kernel.sysctl."kernel.sysrq" = builtins.foldl' (x: y: x + y) 0 [
    4 # enable keyboard controls
    16 # enable filesystem syncing
    32 # enable remounting filesystems read-only
    64 # enable signalling processes
    128 # enable reboot/poweroff
    256 # enable renicing all realtime tasks
  ];

  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
    theme = "nixos-bgrt";

    extraConfig = "DeviceScale=1";
    font = "${pkgs.inter}/share/fonts/truetype/Inter.ttc";
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };

    autoLogin.user = "somasis";
  };

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };

  programs.kde-pim.enable = true; # TODO testing

  programs.kdeconnect.enable = true;

  # RetroArch joysticks and stuff
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  hardware.uinput.enable = true;

  services.usbguard = {
    dbus.enable = true;
    # Automatically allow devices.
    # We will block devices inserted while on the lock screen.
    implicitPolicyTarget = "allow";
  };

  systemd = {
    packages = [ pkgs.usbguard-notifier ];
    user = {
      services.usbguard-notifier = {
        # partOf = [ "graphical-session.target" ];
        wantedBy = [
          "graphical-session.target"
          "unlock.target"
        ];

        # Remove "usbguard.service" dependency, since it doesn't really work
        # after = lib.mkForce [ ];

        # then add back the dependency through a hack since we can't really
        # declare a user service's dependency on a system service.
        # <https://github.com/systemd/systemd/issues/3312>
        # preStart = ''
        #   ${pkgs.systemd-wait}/bin/systemd-wait -q usbguard.service active
        # '';
      };
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

  environment.systemPackages = [
    pkgs.waypipe
    pkgs.usbguard-notifier
  ];
}
