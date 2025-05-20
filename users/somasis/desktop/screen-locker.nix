{ config
, osConfig
, lib
, pkgs
, ...
}:
assert osConfig.services.systemd-lock-handler.enable;
let

  usbguardCfg = osConfig.services.usbguard;
  usbguardPkg = usbguardCfg.package or pkgs.usbguard-nox;
in
{
  services.xssproxy.enable = true;

  systemd.user = {
    target.unlock = {
      Unit.Conflicts = [ "usbguard-notifier.service" ];
      Unit.OnSuccess = [ "usbguard-notifier.service" ];

      Service = {
        ExecStartPre =
          # Disable the ability to switch between virtual terminals.
          [ "-${lib.getExe pkgs.xorg.setxkbmap} -option srvrkeys:none" ]
          # Implement something like GNOME's USBGuard integration
          ++ lib.optionals usbguardCfg.enable [
            "${usbguardPkg}/bin/usbguard set-parameter InsertedDevicePolicy block"
            "${usbguardPkg}/bin/usbguard set-parameter ImplicitPolicyTarget block"
          ];

        ExecStopPost = lib.optionals osConfig.services.usbguard.enable [
          # "${pkgs.systemd}/bin/systemctl --user start usbguard-notifier.service"
          "${usbguardPkg}/bin/usbguard set-parameter InsertedDevicePolicy ${usbguardCfg.insertedDevicePolicy}"
          "${usbguardPkg}/bin/usbguard set-parameter ImplicitPolicyTarget ${usbguardCfg.implicitPolicyTarget}"
        ];
      };
    };

    # Re-initialize keyboard settings when system is unlocked.
    services.setxkbmap = {
      Unit.PartOf = [ "unlock.target" ];
      Install.WantedBy = [ "unlock.target" ];
    };

    # services.xsecurelock-failure = {
    #   Unit.Description = "Bring down the system when xsecurelock fails";
    #   Service.Type = "oneshot";
    #   Service.ExecStart = "${pkgs.systemd}/bin/systemctl poweroff";
    # };
  };

  # I only need this so I can react to logind's lock-session stuff and suspend events
  services.screen-locker = {
    lockCmd = "${pkgs.systemd}/bin/loginctl lock-session";
    inactiveInterval = 15; # lock after x minutes of inactivity

    xautolock.enable = false; # Use xss-lock
    xss-lock = {
      extraOptions = [ "-l" ];
      screensaverCycle = 60 * 15;
    };
  };

  home.packages =
    [
      (pkgs.writeShellApplication {
        name = "toggle-dpms";

        runtimeInputs = [
          pkgs.gnugrep
          pkgs.libnotify
          pkgs.xorg.xset
        ];

        text = ''
          if LC_ALL=C xset q | grep -q 'DPMS is Enabled'; then
              xset -dpms \
                  && exec \
                      notify-send \
                          -a dpms-toggle \
                          -i preferences-desktop-display \
                          'dpms-toggle' \
                          'DPMS disabled, monitor will not go to sleep automatically.'
          else
              xset +dpms \
                  && exec \
                      notify-send \
                          -a dpms-toggle \
                          -i preferences-desktop-display \
                          'dpms-toggle' \
                          'DPMS enabled, monitor will sleep automatically.'
          fi
        '';
      })
    ]
    ++ lib.optional config.services.xsecurelock.enable (
      pkgs.writeShellApplication {
        name = "toggle-xsecurelock";

        runtimeInputs = [
          pkgs.libnotify
          pkgs.systemd
        ];

        text = ''
          if systemctl --user -q is-active xss-lock.service; then
              systemctl --user stop xss-lock.service \
                  && exec \
                      notify-send \
                          -a xsecurelock \
                          -i preferences-desktop-screensaver \
                          'xsecurelock' \
                          'Screensaver disabled, screen will not automatically lock.'
          else \
              systemctl --user start xss-lock.service \
                  && exec \
                      notify-send \
                          -a xsecurelock \
                          -i preferences-desktop-screensaver \
                          'xsecurelock' \
                          'Screensaver enabled, screen will automatically lock.'
          fi
        '';
      }
    );
}
