{
  pkgs,
  lib,
  config,
  ...
}:
{
  services = {
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";

      HandlePowerKey = "sleep";
      HandlePowerKeyLongPress = "poweroff";

      PowerKeyIgnoreInhibited = "yes";
    };

    upower = {
      enable = true;
      criticalPowerAction = "PowerOff";

      percentageLow = 15;
      percentageCritical = 5;
      percentageAction = 0;
    };

    power-profiles-daemon.enable = false;
    tuned = {
      enable = true;
      ppdSettings.main.default = "power-saver";
    };
    tlp.enable = false;

    # Automatically `nice` programs for better performance.
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;

      extraRules = [
        {
          name = "bindfs";
          type = "BG_CPUIO";
        }

        {
          name = "baloorunner";
          type = "BG_CPUIO";
        }

        {
          name = "konversation";
          type = "Chat";
        }
        {
          name = "equibop";
          type = "Chat";
        }
        {
          name = "radiotray-ng";
          type = "Player-Audio";
        }

        {
          name = "darkman";
          type = "Service";
        }
        {
          name = "usbguard-notifier";
          type = "Service";
        }
        {
          name = "systembus-notify";
          type = "Service";
        }
        {
          name = "mpris-scrobbler";
          type = "Service";
        }
        {
          name = "mpris-proxy";
          type = "Service";
        }
        {
          name = "systemd-lock-handler";
          type = "BG_CPUIO";
        }
        {
          name = "zotero";
          type = "Doc-View";
        }
      ];
    };

    systemd-lock-handler.enable = true;
  };

  powerManagement = {
    cpuFreqGovernor = "powersave";

    # Auto-tune with powertop on boot.
    powertop = {
      enable = true;

      # Trigger rules for the devices we disable USB auto-suspend for in services.udev.extraRules
      postStart = ''
        ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=3434 -a idProduct=0a38
        ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=046d -a idProduct=c08a
      '';
    };
  };

  services.udev.extraRules = ''
    # Disable USB auto-suspend for Keychron K3 Max keyboard
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="3434", ATTR{idProduct}=="0a38", TEST=="power/control", ATTR{power/control}="on"

    # Disable USB auto-suspend for Logitech MX Vertical Advanced Ergonomic Mouse
    ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c08a", TEST=="power/control", ATTR{power/control}="on"
  '';

  systemd.shutdown."wine-kill" = pkgs.writeShellScript "wine-kill" ''
    ${pkgs.procps}/bin/pkill '^winedevice\.exe$' || :
    if [[ -n "$(${pkgs.procps}/bin/pgrep '^winedevice\.exe$')" ]]; then
        ${pkgs.procps}/bin/pkill -e -9 '^winedevice\.exe$' || :
    fi
    exit 0
  '';
}
